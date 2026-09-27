import 'package:flutter_test/flutter_test.dart';
import 'package:qari/domain/text/sentence_splitter.dart';

void main() {
  const s = SentenceSplitter();

  group('English', () {
    test('basic split', () {
      expect(s.split('Hello world. How are you? I am fine!'), [
        'Hello world.',
        'How are you?',
        'I am fine!',
      ]);
    });

    test('abbreviations do not split', () {
      expect(
        s.split('Mr. Smith met Dr. Jones at 5 p.m. yesterday. They talked.'),
        ['Mr. Smith met Dr. Jones at 5 p.m. yesterday.', 'They talked.'],
      );
    });

    test('e.g. and i.e. do not split', () {
      expect(
        s.split('Use a tool, e.g. a hammer, i.e. something heavy. Done.'),
        ['Use a tool, e.g. a hammer, i.e. something heavy.', 'Done.'],
      );
    });

    test('initials do not split', () {
      expect(s.split('The author J. K. Rowling wrote it. It sold well.'), [
        'The author J. K. Rowling wrote it.',
        'It sold well.',
      ]);
    });

    test('decimals and versions do not split', () {
      expect(s.split('Pi is 3.14 roughly. Version 2.0.1 shipped.'), [
        'Pi is 3.14 roughly.',
        'Version 2.0.1 shipped.',
      ]);
    });

    test('closing quotes stay with the sentence', () {
      expect(s.split('He said "Stop." Then he left.'), [
        'He said "Stop."',
        'Then he left.',
      ]);
    });

    test('ellipsis and repeated punctuation', () {
      expect(s.split('Wait... What?! Really.'), [
        'Wait...',
        'What?!',
        'Really.',
      ]);
    });

    test('text without final punctuation is kept', () {
      expect(s.split('Chapter One'), ['Chapter One']);
    });
  });

  group('Arabic', () {
    test('splits on Arabic question mark and full stop', () {
      expect(s.split('ذهب الولد إلى المدرسة. هل عاد؟ نعم، عاد مساءً!'), [
        'ذهب الولد إلى المدرسة.',
        'هل عاد؟',
        'نعم، عاد مساءً!',
      ]);
    });

    test('Urdu/Arabic full stop ۔', () {
      expect(s.split('الجملة الأولى۔ الجملة الثانية۔'), [
        'الجملة الأولى۔',
        'الجملة الثانية۔',
      ]);
    });

    test('Arabic comma and semicolon do not split short sentences', () {
      expect(s.split('قرأت الكتاب، ثم نمت؛ وفي الصباح استيقظت.'), [
        'قرأت الكتاب، ثم نمت؛ وفي الصباح استيقظت.',
      ]);
    });

    test('Arabic abbreviation د. does not split', () {
      expect(s.split('قال د. أحمد إن الدرس مهم. ثم غادر.'), [
        'قال د. أحمد إن الدرس مهم.',
        'ثم غادر.',
      ]);
    });
  });

  group('mixed', () {
    test('English and Arabic sentences in one paragraph', () {
      expect(s.split('This is English. هذه جملة عربية؟ Back to English!'), [
        'This is English.',
        'هذه جملة عربية؟',
        'Back to English!',
      ]);
    });
  });

  group('length cap', () {
    const small = SentenceSplitter(maxChars: 40);

    test('long sentence is split at clause punctuation', () {
      final out = small.split(
        'This sentence is rather long, and it keeps going with more words until the end.',
      );
      expect(out.every((c) => c.length <= 40), isTrue);
      expect(out.first, 'This sentence is rather long,');
    });

    test('long Arabic sentence is split at Arabic comma', () {
      final out = small.split(
        'هذه جملة عربية طويلة جدا، وتستمر بكلمات كثيرة حتى النهاية بدون توقف',
      );
      expect(out.every((c) => c.length <= 40), isTrue);
      expect(out.first, 'هذه جملة عربية طويلة جدا،');
    });

    test('no punctuation falls back to spaces', () {
      final out = small.split(List.filled(20, 'word').join(' '));
      expect(out.every((c) => c.length <= 40), isTrue);
      expect(out.join(' '), List.filled(20, 'word').join(' '));
    });

    test('a single huge token is hard-cut', () {
      final out = small.split('x' * 100);
      expect(out.every((c) => c.length <= 40), isTrue);
      expect(out.join(), 'x' * 100);
    });
  });

  group('letterless chunks', () {
    test('list numbers are merged into the following sentence', () {
      expect(s.split('1. First item here.'), ['1. First item here.']);
    });

    test('empty input', () {
      expect(s.split('   '), isEmpty);
    });
  });
}
