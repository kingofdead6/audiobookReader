import 'package:flutter_test/flutter_test.dart';
import 'package:qari/domain/text/arabic_normalizer.dart';

String reverse(String s) => String.fromCharCodes(s.runes.toList().reversed);

void main() {
  const n = ArabicNormalizer();

  group('presentation forms', () {
    test('isolated/initial/medial/final forms map to base letters', () {
      // ﺍ ﻟ ﺴ ﻼ ﻡ  (alef, lam-initial, seen-medial, lam-alef-final, meem)
      expect(n.normalize('ﺍﻟﺴﻼﻡ'), 'السلام');
    });

    test('lam-alef ligature expands to two letters', () {
      expect(n.normalizeForms('ﻻ'), 'لا');
    });

    test('Allah ligature expands', () {
      expect(n.normalizeForms('ﷲ'), 'الله');
    });

    test('isolated harakat forms map to combining marks', () {
      expect(n.normalizeForms('ﺎﹰ'), 'اً');
    });
  });

  group('cleanup', () {
    test('removes tatweel', () {
      expect(n.normalize('الســـــلام'), 'السلام');
    });

    test('removes bidi controls, zero-width chars and BOM', () {
      expect(
        n.normalize('\u200Fمرحبا\u200E \u202Bبك\u202C\u200B\uFEFF'),
        'مرحبا بك',
      );
    });

    test('keeps diacritics (useful for TTS)', () {
      expect(n.normalize('كَتَبَ'), 'كَتَبَ');
    });

    test('unifies Persian yeh and kaf', () {
      expect(n.normalize('کتاب عربی'), 'كتاب عربي');
    });

    test('leaves English untouched', () {
      const s = 'The quick (brown) fox, 3.14 > 2!';
      expect(n.normalize(s), s);
    });

    test('non-breaking and tab spaces become spaces', () {
      expect(n.normalize('a\u00A0b\tc'), 'a b c');
    });
  });

  group('visual (reversed) order', () {
    const logical = 'ذهب الولد إلى المدرسة الجديدة في الصباح الباكر';

    test('logical text is not detected as reversed', () {
      expect(n.isVisualOrder([logical]), isFalse);
      expect(n.normalize(logical), logical);
    });

    test('reversed line is detected and fixed', () {
      final visual = reverse(logical);
      expect(n.isVisualOrder([visual]), isTrue);
      expect(n.normalize(visual), logical);
    });

    test('Latin words and numbers inside a reversed line keep their order', () {
      const expected = 'استخدمنا Python 3 في المدرسة الجديدة والمكتبة العامة';
      // How a visual-order PDF stores it: Arabic reversed, LTR run intact.
      const visual = 'ةماعلا ةبتكملاو ةديدجلا ةسردملا يف Python 3 انمدختسا';
      expect(n.normalize(visual), expected);
    });

    test('brackets are mirrored when reversing', () {
      // Visual-order PDFs store the glyph shapes as drawn, left to right.
      const visual = 'ةديدجلا ةسردملا (ةلاقم) ةماعلا ةبتكملا';
      expect(n.normalize(visual), 'المكتبة العامة (مقالة) المدرسة الجديدة');
    });

    test('lam-alef ligature survives reversal', () {
      // "لا أعرف المدرسة الجديدة" in visual order, lam-alef as one glyph.
      const visual = 'ةديدجلا ةسردملا فرعأ ﻻ';
      expect(n.normalize(visual), 'لا أعرف المدرسة الجديدة');
    });

    test('decision is per block; English lines are never reversed', () {
      final block = '${reverse(logical)}\nChapter 1: Introduction';
      expect(n.normalize(block), '$logical\nChapter 1: Introduction');
    });
  });

  group('orphan letters', () {
    test('split word ending is re-joined', () {
      expect(
        n.normalize('بِسْ مِ اللَّهِ الرَّحْمَنِ الرَّحِي مِ.'),
        'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ.',
      );
    });

    test('the conjunction و stays a separate word', () {
      expect(n.normalize('كتب و قرأ'), 'كتب و قرأ');
    });

    test('lone letter after a non-joining letter is left alone', () {
      expect(n.normalize('دار ج'), 'دار ج');
    });
  });
}
