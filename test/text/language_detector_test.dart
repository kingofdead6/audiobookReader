import 'package:flutter_test/flutter_test.dart';
import 'package:qari/domain/entities/lang.dart';
import 'package:qari/domain/text/language_detector.dart';

void main() {
  const d = LanguageDetector();

  group('detect', () {
    test('English sentence', () {
      expect(d.detect('The quick brown fox jumps over the lazy dog.'), Lang.en);
    });

    test('Arabic sentence', () {
      expect(d.detect('ذهب الولد إلى المدرسة في الصباح.'), Lang.ar);
    });

    test('Arabic with diacritics', () {
      expect(d.detect('بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ'), Lang.ar);
    });

    test('Arabic presentation forms count as Arabic', () {
      expect(d.detect('ﺍﻟﺴﻼﻡ ﻋﻠﻴﻜﻢ'), Lang.ar);
    });

    test('mostly Arabic with one English term stays Arabic', () {
      expect(d.detect('نستخدم لغة Python في هذا المشروع'), Lang.ar);
    });

    test('mostly English with one Arabic word stays English', () {
      expect(d.detect('The word كتاب means book in Arabic.'), Lang.en);
    });

    test('accented Latin is English/Latin', () {
      expect(d.detect('café naïve résumé'), Lang.en);
    });

    test('no letters returns null', () {
      expect(d.detect('123 — 456 ، ؟'), isNull);
      expect(d.detect(''), isNull);
      expect(d.detectOr('٣٤٥', Lang.ar), Lang.ar);
    });
  });

  group('segment', () {
    test('single-language text is one segment', () {
      final s = d.segment('Hello there, how are you today?');
      expect(s, [
        const LangSegment('Hello there, how are you today?', Lang.en),
      ]);
    });

    test('mixed sentence with long runs splits by language', () {
      final s = d.segment(
        'قمنا بتدريب النموذج باستخدام the transformer architecture from Google ثم قمنا بتقييمه',
      );
      expect(s.map((e) => e.lang).toList(), [Lang.ar, Lang.en, Lang.ar]);
      expect(s[1].text, 'the transformer architecture from Google');
      expect(s[0].text, 'قمنا بتدريب النموذج باستخدام');
    });

    test('short foreign run (loanword) is not split out', () {
      final s = d.segment('نستخدم لغة Python في هذا المشروع الكبير');
      expect(s, hasLength(1));
      expect(s.single.lang, Lang.ar);
    });

    test('neutral tokens attach to surrounding run', () {
      final s = d.segment('In 2020 , we published 3 papers');
      expect(s, hasLength(1));
      expect(s.single.lang, Lang.en);
    });

    test('empty input', () {
      expect(d.segment('   '), isEmpty);
    });
  });
}
