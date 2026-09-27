import '../entities/lang.dart';

/// Script-based language detection. Arabic vs Latin is decided by counting
/// letters in the Arabic Unicode blocks versus Latin letters; digits,
/// punctuation and whitespace are neutral.
class LanguageDetector {
  const LanguageDetector();

  static bool isArabicCodePoint(int c) =>
      (c >= 0x0600 && c <= 0x06FF) || // Arabic
      (c >= 0x0750 && c <= 0x077F) || // Arabic Supplement
      (c >= 0x0870 && c <= 0x08FF) || // Arabic Extended-B/-A
      (c >= 0xFB50 && c <= 0xFDFF) || // Presentation Forms-A
      (c >= 0xFE70 && c <= 0xFEFC); //   Presentation Forms-B

  /// Arabic *letters* (excludes Arabic punctuation, digits and diacritics),
  /// so that e.g. a lone "،" does not count as Arabic text.
  static bool isArabicLetter(int c) {
    if (!isArabicCodePoint(c)) return false;
    if (c >= 0x0660 && c <= 0x0669) return false; // Arabic-Indic digits
    if (c >= 0x06F0 && c <= 0x06F9) return false; // Extended digits
    if (c >= 0x064B && c <= 0x065F) return false; // harakat
    if (c == 0x0670) return false; // superscript alef
    if (c >= 0x06D6 && c <= 0x06ED) return false; // Quranic marks
    if (c == 0x060C || c == 0x061B || c == 0x061F || c == 0x06D4) {
      return false; // ، ؛ ؟ ۔
    }
    if (c == 0x0640) return false; // tatweel
    return true;
  }

  static bool isLatinLetter(int c) =>
      (c >= 0x41 && c <= 0x5A) ||
      (c >= 0x61 && c <= 0x7A) ||
      (c >= 0xC0 && c <= 0x24F && c != 0xD7 && c != 0xF7);

  /// Returns the language of [text], or null when it has no letters at all
  /// (e.g. "123" or "—"), so callers can inherit a neighbour's language.
  Lang? detect(String text) {
    var ar = 0;
    var lat = 0;
    for (final c in text.runes) {
      if (isArabicLetter(c)) {
        ar++;
      } else if (isLatinLetter(c)) {
        lat++;
      }
    }
    if (ar == 0 && lat == 0) return null;
    // Arabic words are shorter in letters than their English counterparts, so
    // weight Arabic slightly: a mostly-Arabic sentence with one English term
    // stays Arabic.
    return ar * 1.3 >= lat ? Lang.ar : Lang.en;
  }

  Lang detectOr(String text, Lang fallback) => detect(text) ?? fallback;

  /// Splits [text] into runs of a single language so a mixed sentence like
  /// "قمنا بتدريب the transformer model على البيانات" can be voiced by two
  /// engines. Foreign runs shorter than [minRunWords] words stay inside the
  /// surrounding run (the voice will just read them with an accent), which
  /// avoids choppy switching for single loanwords or acronyms.
  List<LangSegment> segment(
    String text, {
    Lang fallback = Lang.en,
    int minRunWords = 3,
  }) {
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final tagged = <(String, Lang?)>[for (final w in words) (w, detect(w))];
    if (tagged.isEmpty) return const [];

    // Group consecutive words of the same language; neutral words join the
    // current run.
    final runs = <_Run>[];
    for (final (word, lang) in tagged) {
      if (runs.isEmpty) {
        runs.add(_Run(lang, [word]));
      } else if (lang == null ||
          runs.last.lang == null ||
          runs.last.lang == lang) {
        runs.last.lang ??= lang;
        runs.last.words.add(word);
      } else {
        runs.add(_Run(lang, [word]));
      }
    }

    // Repeatedly fold the shortest too-short run into its larger neighbour,
    // then coalesce neighbours that now share a language.
    while (runs.length > 1) {
      var shortest = -1;
      for (var i = 0; i < runs.length; i++) {
        final n = runs[i].letterWords;
        if (n < minRunWords &&
            (shortest < 0 || n < runs[shortest].letterWords)) {
          shortest = i;
        }
      }
      if (shortest < 0) break;
      final r = runs.removeAt(shortest);
      final prev = shortest > 0 ? runs[shortest - 1] : null;
      final next = shortest < runs.length ? runs[shortest] : null;
      if (next == null ||
          (prev != null && prev.letterWords >= next.letterWords)) {
        prev!.words.addAll(r.words);
      } else {
        next.words.insertAll(0, r.words);
      }
      for (var i = runs.length - 1; i > 0; i--) {
        if (runs[i].lang == runs[i - 1].lang) {
          runs[i - 1].words.addAll(runs[i].words);
          runs.removeAt(i);
        }
      }
    }

    return [
      for (final r in runs)
        LangSegment(r.words.join(' '), r.lang ?? detect(text) ?? fallback),
    ];
  }
}

class LangSegment {
  const LangSegment(this.text, this.lang);
  final String text;
  final Lang lang;

  @override
  String toString() => 'LangSegment(${lang.name}: $text)';

  @override
  bool operator ==(Object other) =>
      other is LangSegment && other.text == text && other.lang == lang;

  @override
  int get hashCode => Object.hash(text, lang);
}

class _Run {
  _Run(this.lang, this.words);
  Lang? lang;
  final List<String> words;

  int get letterWords =>
      words.where((w) => const LanguageDetector().detect(w) != null).length;
}
