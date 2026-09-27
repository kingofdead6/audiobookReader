import 'arabic_normalizer.dart';
import 'language_detector.dart';

/// Result of cleaning one PDF page.
class CleanPage {
  const CleanPage({required this.paragraphs, required this.hasText});

  /// Paragraphs in reading order, whitespace-normalized.
  final List<String> paragraphs;

  /// False when the page has no usable text layer (scanned image or blank).
  final bool hasText;

  String get text => paragraphs.join('\n\n');
}

/// Turns raw per-page PDF text into clean paragraphs:
/// normalization, running header/footer and page-number removal,
/// de-hyphenation and line-to-paragraph merging.
class TextCleaner {
  const TextCleaner({this.normalizer = const ArabicNormalizer()});

  final ArabicNormalizer normalizer;

  /// Pages with fewer letters than this are treated as having no text layer.
  static const minLettersForText = 3;

  /// How many lines at the top/bottom of a page are candidates for running
  /// headers, footers and page numbers.
  static const _edgeLines = 2;

  static final _spaces = RegExp(r' {2,}');
  static final _digits = RegExp(r'[0-9٠-٩۰-۹]+');

  /// "12", "- 12 -", "Page 12", "Page 12 of 300", "12/300", "صفحة ١٢", "xiv".
  static final pageNumberLine = RegExp(
    r'^[\-–—\s]*(?:page|p\.|pg\.?|صفحة|ص\.?)?\s*'
    r'(?:[0-9٠-٩۰-۹]+|[ivxlcdm]{1,7})'
    r'\s*(?:(?:of|/|من)\s*[0-9٠-٩۰-۹]+)?[\-–—\s]*$',
    caseSensitive: false,
  );

  static final _bulletStart = RegExp(r'^(?:[•▪◦●■\-–*]|\d{1,3}[.)])\s');
  static const _terminal = '.!?…؟۔:"”»\'';

  List<CleanPage> cleanPages(List<String> rawPages) {
    final pagesLines = [for (final raw in rawPages) _lines(raw)];
    final repeated = _findRunningLines(pagesLines);

    return [for (final lines in pagesLines) _cleanPage(lines, repeated)];
  }

  List<String> _lines(String raw) {
    final normalized = normalizer.normalize(raw);
    return [
      for (final l in normalized.split('\n'))
        if (l.trim().isNotEmpty) l.replaceAll(_spaces, ' ').trim(),
    ];
  }

  static String _edgeKey(String line) =>
      line.toLowerCase().replaceAll(_digits, '#');

  /// Lines that recur at the top or bottom of many pages (book title,
  /// chapter name, "Page # of #") are running headers/footers.
  Set<String> _findRunningLines(List<List<String>> pages) {
    final withText = pages.where((p) => p.isNotEmpty).length;
    if (withText < 4) return const {};
    final counts = <String, int>{};
    for (final lines in pages) {
      final keys = <String>{for (final l in _edges(lines)) _edgeKey(l)};
      for (final k in keys) {
        counts[k] = (counts[k] ?? 0) + 1;
      }
    }
    final threshold = (withText * 0.4).ceil().clamp(3, 1 << 30);
    return {
      for (final e in counts.entries)
        if (e.value >= threshold) e.key,
    };
  }

  Iterable<String> _edges(List<String> lines) sync* {
    for (var i = 0; i < lines.length; i++) {
      if (_isEdge(i, lines.length) && _headerLike(lines[i])) yield lines[i];
    }
  }

  /// Short pages only have one candidate line at each end, so body text on
  /// a three-line page is never mistaken for a header.
  static bool _isEdge(int i, int count) {
    final n = count >= 3 * _edgeLines ? _edgeLines : 1;
    return i < n || i >= count - n;
  }

  /// Running headers/footers do not end like sentences.
  static bool _headerLike(String line) =>
      line.length <= 100 && !'.!?؟۔'.contains(line[line.length - 1]);

  CleanPage _cleanPage(List<String> lines, Set<String> repeated) {
    final kept = <String>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (_isEdge(i, lines.length) &&
          ((_headerLike(line) && repeated.contains(_edgeKey(line))) ||
              pageNumberLine.hasMatch(line))) {
        continue;
      }
      kept.add(line);
    }

    final letters = kept.fold<int>(
      0,
      (n, l) =>
          n +
          l.runes
              .where(
                (c) =>
                    LanguageDetector.isArabicLetter(c) ||
                    LanguageDetector.isLatinLetter(c),
              )
              .length,
    );
    if (letters < minLettersForText) {
      return const CleanPage(paragraphs: [], hasText: false);
    }
    return CleanPage(paragraphs: mergeLines(kept), hasText: true);
  }

  /// Joins PDF lines into paragraphs. A line ends a paragraph when it ends a
  /// sentence and is noticeably shorter than a full line, or when it looks
  /// like a heading (short, no final punctuation). Words hyphenated across a
  /// line break are rejoined.
  List<String> mergeLines(List<String> input) {
    if (input.isEmpty) return const [];
    final lines = List.of(input);
    final lengths = [
      for (final l in lines)
        if (l.length >= 20) l.length,
    ]..sort();
    final median = lengths.isEmpty
        ? 0
        : lengths[lengths.length ~/ 2].toDouble();

    final paragraphs = <String>[];
    final current = StringBuffer();

    void flush() {
      final p = current.toString().replaceAll(_spaces, ' ').trim();
      if (p.isNotEmpty) paragraphs.add(p);
      current.clear();
    }

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final next = i + 1 < lines.length ? lines[i + 1] : null;

      if (next != null && _bulletStart.hasMatch(next)) {
        _append(current, line);
        flush();
        continue;
      }

      if (next != null && _endsWithHyphen(line) && _startsLower(next)) {
        // "exam-" + "ple" -> "example"
        current.write(current.isEmpty ? '' : ' ');
        current.write(line.substring(0, line.length - 1));
        lines[i + 1] = '\u0000$next'; // marker: glue without a space
        continue;
      }

      _append(current, line);

      final endsSentence = _terminal.contains(line[line.length - 1]);
      final short = median > 0 && line.length < median * 0.85;
      final veryShort = median > 0 && line.length < median * 0.6;
      if (next == null ||
          (endsSentence && (short || median == 0)) ||
          (!endsSentence && veryShort)) {
        flush();
      }
    }
    flush();
    return paragraphs;
  }

  static void _append(StringBuffer b, String line) {
    if (line.startsWith('\u0000')) {
      b.write(line.substring(1));
    } else {
      if (b.isNotEmpty) b.write(' ');
      b.write(line);
    }
  }

  static bool _endsWithHyphen(String line) {
    if (line.length < 3) return false;
    final last = line[line.length - 1];
    if (last != '-' && last != '‐') return false;
    return LanguageDetector.isLatinLetter(line.codeUnitAt(line.length - 2));
  }

  static bool _startsLower(String line) {
    final s = line.startsWith('\u0000') ? line.substring(1) : line;
    if (s.isEmpty) return false;
    final c = s.codeUnitAt(0);
    return c >= 0x61 && c <= 0x7A;
  }
}
