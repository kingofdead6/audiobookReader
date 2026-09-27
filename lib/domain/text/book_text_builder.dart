import '../entities/lang.dart';
import '../entities/page_content.dart';
import '../entities/sentence.dart';
import 'language_detector.dart';
import 'sentence_splitter.dart';
import 'text_cleaner.dart';

/// Full text pipeline: raw page strings from the PDF -> cleaned paragraphs
/// -> sentences -> per-language chunks with global indices.
///
/// Pure Dart with no I/O, so it runs inside `Isolate.run` during import.
class BookTextBuilder {
  const BookTextBuilder({
    this.cleaner = const TextCleaner(),
    this.splitter = const SentenceSplitter(),
    this.detector = const LanguageDetector(),
  });

  final TextCleaner cleaner;
  final SentenceSplitter splitter;
  final LanguageDetector detector;

  List<PageContent> build(List<String> rawPages) {
    final cleaned = cleaner.cleanPages(rawPages);
    final bookLang = _dominantLang(cleaned);

    final pages = <PageContent>[];
    var global = 0;
    var lastLang = bookLang;
    for (var p = 0; p < cleaned.length; p++) {
      final page = cleaned[p];
      final sentences = <Sentence>[];
      for (var para = 0; para < page.paragraphs.length; para++) {
        for (final s in splitter.split(page.paragraphs[para])) {
          for (final seg in detector.segment(s, fallback: lastLang)) {
            lastLang = seg.lang;
            sentences.add(
              Sentence(
                pageIndex: p,
                indexInPage: sentences.length,
                globalIndex: global++,
                paragraph: para,
                text: seg.text,
                lang: seg.lang,
              ),
            );
          }
        }
      }
      pages.add(
        PageContent(
          pageIndex: p,
          hasText: page.hasText && sentences.isNotEmpty,
          sentences: sentences,
        ),
      );
    }
    return pages;
  }

  Lang _dominantLang(List<CleanPage> pages) {
    var ar = 0;
    var en = 0;
    for (final p in pages.take(20)) {
      for (final c in p.text.runes) {
        if (LanguageDetector.isArabicLetter(c)) {
          ar++;
        } else if (LanguageDetector.isLatinLetter(c)) {
          en++;
        }
      }
    }
    return ar > en ? Lang.ar : Lang.en;
  }
}
