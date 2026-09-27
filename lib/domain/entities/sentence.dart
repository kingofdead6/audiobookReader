import 'lang.dart';

/// The unit the player speaks and highlights. Usually one sentence; a
/// mixed-language sentence is split into one [Sentence] per language run.
class Sentence {
  const Sentence({
    required this.pageIndex,
    required this.indexInPage,
    required this.globalIndex,
    required this.paragraph,
    required this.text,
    required this.lang,
  });

  final int pageIndex;
  final int indexInPage;

  /// Position in the whole book; used for progress and resume.
  final int globalIndex;

  /// Paragraph number within the page, for layout.
  final int paragraph;
  final String text;
  final Lang lang;

  @override
  String toString() => 'Sentence(p$pageIndex#$indexInPage ${lang.name}: $text)';
}
