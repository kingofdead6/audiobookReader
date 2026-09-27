import 'sentence.dart';

/// Cleaned text of one PDF page, split into speakable sentences.
class PageContent {
  const PageContent({
    required this.pageIndex,
    required this.hasText,
    required this.sentences,
  });

  /// Zero-based page index.
  final int pageIndex;

  /// False for scanned/blank pages without a text layer; they are skipped
  /// during playback and flagged in the UI.
  final bool hasText;
  final List<Sentence> sentences;

  /// Sentences grouped by paragraph, in order.
  List<List<Sentence>> get paragraphs {
    final out = <List<Sentence>>[];
    for (final s in sentences) {
      if (out.isEmpty || out.last.first.paragraph != s.paragraph) {
        out.add([s]);
      } else {
        out.last.add(s);
      }
    }
    return out;
  }
}
