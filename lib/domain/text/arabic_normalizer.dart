import 'arabic_presentation_forms.g.dart';
import 'language_detector.dart';

/// Cleans Arabic text extracted from PDFs so it reads correctly and is
/// speakable by a TTS engine.
///
/// Order matters:
///  1. strip bidi/zero-width control characters
///  2. map single-letter presentation forms (U+FB50–U+FEFF) to base letters,
///     keeping multi-letter ligatures (e.g. U+FEFB "ﻻ") as one code point
///  3. drop tatweel, unify Persian yeh/kaf
///  4. detect lines stored in visual (reversed) order and flip them — the
///     ligatures are still single code points here, so they move as a unit
///  5. expand the remaining ligatures to their letters
class ArabicNormalizer {
  const ArabicNormalizer();

  static const _tatweel = 0x0640;
  static const _taMarbuta = 0x0629;
  static const _alefMaqsura = 0x0649;
  static const _alef = 0x0627;
  static const _lam = 0x0644;

  static final _controls = RegExp(
    '[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F\u00AD\u061C'
    '\u200B\u200E\u200F\u202A-\u202E\u2066-\u2069\uFEFF]',
  );

  static const _mirror = {
    0x28: 0x29, 0x29: 0x28, // ( )
    0x5B: 0x5D, 0x5D: 0x5B, // [ ]
    0x7B: 0x7D, 0x7D: 0x7B, // { }
    0x3C: 0x3E, 0x3E: 0x3C, // < >
    0xAB: 0xBB, 0xBB: 0xAB, // « »
  };

  /// Full pipeline for a block of text (one PDF page). Reversal is decided
  /// for the whole block, because a PDF producer either writes visual order
  /// everywhere or nowhere; per-line decisions are too noisy on short lines.
  String normalize(String text) {
    var t = stripControls(text);
    t = _mapSingleForms(t);
    final lines = t.split('\n');
    if (isVisualOrder(lines)) {
      for (var i = 0; i < lines.length; i++) {
        if (_hasArabicLetter(lines[i])) lines[i] = reverseVisualLine(lines[i]);
      }
    }
    return lines.map((l) => joinOrphanLetters(_expandLigatures(l))).join('\n');
  }

  /// Removes invisible formatting characters and unifies line separators.
  String stripControls(String text) => text
      .replaceAll('\r\n', '\n')
      .replaceAll(RegExp('[\r\u2028\u2029\u0085]'), '\n')
      .replaceAll(RegExp('[\t\u00A0\u2000-\u200A\u202F\u205F\u3000]'), ' ')
      .replaceAll(_controls, '');

  String _mapSingleForms(String text) {
    final out = StringBuffer();
    for (final c in text.runes) {
      if (c == _tatweel) continue;
      if (c == 0x06CC) {
        out.writeCharCode(0x064A); // Persian yeh -> Arabic yeh
        continue;
      }
      if (c == 0x06A9) {
        out.writeCharCode(0x0643); // Persian kaf -> Arabic kaf
        continue;
      }
      final mapped = arabicPresentationForms[c];
      if (mapped != null && mapped.runes.length == 1) {
        final m = mapped.runes.first;
        if (m != _tatweel) out.writeCharCode(m);
      } else {
        out.writeCharCode(c);
      }
    }
    return out.toString();
  }

  String _expandLigatures(String text) {
    final out = StringBuffer();
    for (final c in text.runes) {
      final mapped = arabicPresentationForms[c];
      if (mapped != null) {
        out.write(mapped.replaceAll('ـ', ''));
      } else {
        out.writeCharCode(c);
      }
    }
    return out.toString();
  }

  /// Letters that connect to the following letter; a word ending in one of
  /// them cannot be followed by a lone letter of the same word.
  static const _joiners = 'بتثجحخسشصضطظعغفقكلمنهيئ';
  static const _marks = '\u064B-\u065F\u0670';
  static final _orphan = RegExp(
    '([$_joiners][$_marks]*) ([ء-يٱ][$_marks]*)(?=[\\s.،؛؟!:]|\$)',
  );

  /// PDF producers sometimes split a fully vocalized word before its last
  /// letter ("الرَّحِي مِ"). A single letter other than و (and) after a
  /// word ending in a joining letter is re-attached.
  String joinOrphanLetters(String line) => line.replaceAllMapped(
    _orphan,
    (m) => m[2]!.startsWith('و') ? m[0]! : '${m[1]}${m[2]}',
  );

  /// Maps presentation forms and expands ligatures without reversal
  /// detection. Useful for short strings.
  String normalizeForms(String text) =>
      _expandLigatures(_mapSingleForms(stripControls(text)));

  /// Heuristic: in logical order no Arabic word starts with ة or ى, and many
  /// words start with "ال". In visual order these patterns flip: words start
  /// with ة/ى and end with "لا".
  bool isVisualOrder(List<String> lines) {
    var logical = 0;
    var reversed = 0;
    for (final line in lines) {
      for (final raw in line.split(' ')) {
        final w = _arabicCore(raw);
        if (w.length < 2) continue;
        final first = w.first;
        final last = w.last;
        if (first == _taMarbuta || first == _alefMaqsura) reversed += 2;
        if (last == _taMarbuta || last == _alefMaqsura) logical += 2;
        if (w.length >= 4) {
          if (first == _alef && w[1] == _lam) logical += 1;
          if (last == _alef && w[w.length - 2] == _lam) reversed += 1;
        }
      }
    }
    return reversed >= 2 && reversed > logical * 1.5;
  }

  /// Reverses a visually ordered line into logical order while keeping runs
  /// of Latin text and numbers (which PDFs store left-to-right) intact, and
  /// mirroring brackets in the Arabic parts.
  String reverseVisualLine(String line) {
    final chars = line.runes.toList().reversed.toList();
    final out = <int>[];
    var i = 0;
    while (i < chars.length) {
      final c = chars[i];
      if (_isStrongLtr(c)) {
        // Extend over neutrals until an Arabic letter; the run ends at the
        // last strong LTR char seen.
        var k = i;
        var lastStrong = i;
        while (k < chars.length && !LanguageDetector.isArabicLetter(chars[k])) {
          if (_isStrongLtr(chars[k])) lastStrong = k;
          k++;
        }
        out.addAll(chars.sublist(i, lastStrong + 1).reversed);
        i = lastStrong + 1;
      } else {
        out.add(_mirror[c] ?? c);
        i++;
      }
    }
    return String.fromCharCodes(out);
  }

  static bool _isStrongLtr(int c) =>
      LanguageDetector.isLatinLetter(c) ||
      (c >= 0x30 && c <= 0x39) ||
      (c >= 0x0660 && c <= 0x0669) ||
      (c >= 0x06F0 && c <= 0x06F9);

  static bool _hasArabicLetter(String s) =>
      s.runes.any(LanguageDetector.isArabicLetter);

  /// The Arabic letters of a token, with diacritics and surrounding
  /// punctuation removed.
  static List<int> _arabicCore(String token) =>
      token.runes.where(LanguageDetector.isArabicLetter).toList();
}
