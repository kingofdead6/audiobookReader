import 'package:flutter_test/flutter_test.dart';
import 'package:qari/domain/entities/lang.dart';
import 'package:qari/domain/text/book_text_builder.dart';

void main() {
  const b = BookTextBuilder();

  test('builds sentences with global indices, languages and empty pages', () {
    final pages = b.build([
      'Hello world. This is page one.',
      '',
      'ذهب الولد إلى المدرسة. هل عاد؟',
    ]);
    expect(pages, hasLength(3));
    expect(pages[0].sentences.map((s) => s.text), [
      'Hello world.',
      'This is page one.',
    ]);
    expect(pages[0].sentences.every((s) => s.lang == Lang.en), isTrue);
    expect(pages[1].hasText, isFalse);
    expect(pages[1].sentences, isEmpty);
    expect(pages[2].sentences.map((s) => s.lang), [Lang.ar, Lang.ar]);
    expect(pages[2].sentences.map((s) => s.globalIndex), [2, 3]);
    expect(pages[2].sentences.map((s) => s.indexInPage), [0, 1]);
  });

  test('mixed page: sentences keep their own language', () {
    final pages = b.build([
      'This book is bilingual. هذا الكتاب ثنائي اللغة. Enjoy reading!',
    ]);
    expect(pages.single.sentences.map((s) => s.lang), [
      Lang.en,
      Lang.ar,
      Lang.en,
    ]);
  });

  test('visually ordered Arabic page is fixed end to end', () {
    const visual = 'حابصلا يف ةديدجلا ةسردملا ىلإ دلولا بهذ';
    final pages = b.build([visual]);
    expect(
      pages.single.sentences.single.text,
      'ذهب الولد إلى المدرسة الجديدة في الصباح',
    );
  });
}
