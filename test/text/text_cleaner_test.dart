import 'package:flutter_test/flutter_test.dart';
import 'package:qari/domain/text/text_cleaner.dart';

void main() {
  const c = TextCleaner();

  test('page-number line patterns', () {
    for (final l in [
      '12',
      '- 12 -',
      'Page 12',
      'Page 12 of 300',
      '12/300',
      'صفحة ١٢',
      '١٢',
      'xiv',
      'ص ٤٥',
    ]) {
      expect(TextCleaner.pageNumberLine.hasMatch(l), isTrue, reason: l);
    }
    for (final l in ['Chapter 12', '12 apples fell', 'في عام ٢٠٢٠ حدث']) {
      expect(TextCleaner.pageNumberLine.hasMatch(l), isFalse, reason: l);
    }
  });

  test('running headers, footers and page numbers are removed', () {
    final pages = [
      for (var i = 1; i <= 6; i++)
        'The Great Book\nBody text of page $i goes here.\n$i',
    ];
    final out = c.cleanPages(pages);
    for (var i = 0; i < 6; i++) {
      expect(out[i].text, 'Body text of page ${i + 1} goes here.');
    }
  });

  test('Arabic running header with page number is removed', () {
    final pages = [
      for (var i = 1; i <= 5; i++) 'كتاب التاريخ - $i\nهذا نص الصفحة رقم $i.',
    ];
    final out = c.cleanPages(pages);
    expect(out[2].text, 'هذا نص الصفحة رقم 3.');
  });

  test('hyphenated words across lines are merged', () {
    expect(c.mergeLines(['This is an exam-', 'ple of hyphenation.']), [
      'This is an example of hyphenation.',
    ]);
  });

  test('capitalised continuation after hyphen keeps the hyphen', () {
    expect(c.mergeLines(['A well known Anglo-', 'Saxon word.']), [
      'A well known Anglo- Saxon word.',
    ]);
  });

  test('lines are merged into paragraphs; short final lines end them', () {
    final lines = [
      'This is the first line of a long paragraph that wraps',
      'onto a second line of about the same length here and',
      'ends here.',
      'A new paragraph starts on this line and it is quite long',
      'and then it finishes on this final line of the page.',
    ];
    expect(c.mergeLines(lines), [
      'This is the first line of a long paragraph that wraps onto a second line of about the same length here and ends here.',
      'A new paragraph starts on this line and it is quite long and then it finishes on this final line of the page.',
    ]);
  });

  test('short heading without punctuation becomes its own paragraph', () {
    final lines = [
      'Chapter One',
      'It was a bright cold day in April, and the clocks were',
      'striking thirteen as the story begins in this example.',
    ];
    expect(c.mergeLines(lines).first, 'Chapter One');
  });

  test('bullet items start new paragraphs', () {
    expect(c.mergeLines(['Things to buy:', '• milk and eggs', '• bread']), [
      'Things to buy:',
      '• milk and eggs',
      '• bread',
    ]);
  });

  test('page without letters is marked as having no text layer', () {
    final out = c.cleanPages(['', '  \n 12 \n', 'Real text on this page.']);
    expect(out[0].hasText, isFalse);
    expect(out[1].hasText, isFalse);
    expect(out[2].hasText, isTrue);
  });
}
