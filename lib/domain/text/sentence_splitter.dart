import 'language_detector.dart';

/// Splits a paragraph into sentences for English and Arabic, then caps each
/// chunk at [maxChars] so a TTS engine never receives an overly long input.
class SentenceSplitter {
  const SentenceSplitter({this.maxChars = 280});

  /// Hard upper bound for a chunk sent to a TTS engine.
  final int maxChars;

  /// Sentence-ending characters: . ! ? … and Arabic ؟ ۔
  static const _terminals = '.!?…؟۔';

  /// Characters that may follow a terminal and still belong to the sentence.
  static const _closers = '.!?…؟۔"\'”’»)]';

  /// Clause separators used to break long sentences: , ; : ، ؛ and dashes.
  static const _soft = ',;:،؛—–';

  /// Lower-cased abbreviations (without the final dot) that do not end a
  /// sentence.
  static const abbreviations = {
    'mr', 'mrs', 'ms', 'dr', 'prof', 'sr', 'jr', 'st', 'mt', 'vs', 'etc',
    'e.g', 'i.e', 'cf', 'inc', 'ltd', 'co', 'corp', 'no', 'nos', 'fig',
    'figs', 'vol', 'vols', 'ch', 'chap', 'sec', 'pp', 'p', 'ed', 'eds',
    'al', 'approx', 'dept', 'est', 'gen', 'gov', 'lt', 'col', 'capt', 'sgt',
    'rev', 'jan', 'feb', 'mar', 'apr', 'jun', 'jul', 'aug', 'sep', 'sept',
    'oct', 'nov', 'dec', 'u.s', 'u.k', 'u.n', 'a.m', 'p.m', 'ph.d', 'b.c',
    'a.d', 'op', 'ibid', 'viz',
    // Arabic: د. (Dr.), أ. (Prof.), أ.د (Prof. Dr.)
    'د', 'أ', 'أ.د',
  };

  List<String> split(String paragraph) {
    final text = paragraph.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.isEmpty) return const [];

    final sentences = <String>[];
    var start = 0;
    var i = 0;
    while (i < text.length) {
      final ch = text[i];
      if (!_terminals.contains(ch)) {
        i++;
        continue;
      }
      var j = i + 1;
      while (j < text.length && _closers.contains(text[j])) {
        j++;
      }
      final atEnd = j >= text.length;
      if (!atEnd && text[j] != ' ') {
        // "3.14", "e.g.x", "U.S." inside a token: not a boundary.
        i = j;
        continue;
      }
      if (ch == '.' &&
          text.substring(i, j).replaceAll(RegExp('[^.]'), '').length == 1 &&
          _isAbbreviation(text, i, j)) {
        i = j;
        continue;
      }
      _add(sentences, text.substring(start, j));
      start = j;
      i = j;
    }
    if (start < text.length) _add(sentences, text.substring(start));

    return _mergeLetterless([for (final s in sentences) ..._capLength(s)]);
  }

  static void _add(List<String> out, String s) {
    final t = s.trim();
    if (t.isNotEmpty) out.add(t);
  }

  /// [dot] is the index of the '.', [after] the index after trailing closers.
  bool _isAbbreviation(String text, int dot, int after) {
    var s = dot;
    while (s > 0 && text[s - 1] != ' ') {
      s--;
    }
    var token = text.substring(s, dot);
    token = token.replaceAll(RegExp('^[("\'“‘«\\[]+'), '');
    if (token.isEmpty) return false;
    final lower = token.toLowerCase();
    if (abbreviations.contains(lower)) return true;
    // Initials: "J. K. Rowling"
    if (token.length == 1 &&
        LanguageDetector.isLatinLetter(token.codeUnitAt(0)) &&
        token.toUpperCase() == token) {
      return true;
    }
    // Next word starts in lower case -> the dot was not a sentence end.
    final next = _nextWordStart(text, after);
    if (next != null && next >= 0x61 && next <= 0x7A) return true;
    return false;
  }

  static int? _nextWordStart(String text, int from) {
    for (var k = from; k < text.length; k++) {
      final c = text.codeUnitAt(k);
      if (c == 0x20) continue;
      return c;
    }
    return null;
  }

  /// Splits sentences longer than [maxChars] at clause punctuation, then at
  /// spaces, and as a last resort mid-token.
  List<String> _capLength(String sentence) {
    final out = <String>[];
    var rest = sentence;
    while (rest.length > maxChars) {
      final window = rest.substring(0, maxChars + 1);
      final minCut = (maxChars * 0.3).round();
      var cut = -1;
      for (var k = window.length - 1; k >= minCut; k--) {
        if (_soft.contains(window[k]) &&
            (k + 1 >= rest.length || rest[k + 1] == ' ')) {
          cut = k + 1;
          break;
        }
      }
      if (cut < 0) {
        final space = window.lastIndexOf(' ');
        cut = space >= minCut ? space : maxChars;
      }
      _add(out, rest.substring(0, cut));
      rest = rest.substring(cut).trim();
    }
    _add(out, rest);
    return out;
  }

  /// Chunks with no letters ("1.", "*", "—") are glued to the next chunk
  /// (or the previous one at the end) so the engine never speaks them alone.
  static List<String> _mergeLetterless(List<String> chunks) {
    final out = <String>[];
    String? carry;
    for (final c in chunks) {
      final hasLetters = c.runes.any(
        (r) =>
            LanguageDetector.isLatinLetter(r) ||
            LanguageDetector.isArabicLetter(r),
      );
      if (!hasLetters) {
        carry = carry == null ? c : '$carry $c';
        continue;
      }
      out.add(carry == null ? c : '$carry $c');
      carry = null;
    }
    if (carry != null) {
      if (out.isEmpty) {
        out.add(carry);
      } else {
        out[out.length - 1] = '${out.last} $carry';
      }
    }
    return out;
  }
}
