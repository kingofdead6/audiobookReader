import 'package:flutter_test/flutter_test.dart';
import 'package:qari/domain/text/line_rebuilder.dart';

/// (char, left, top, right, bottom) as reported by PDFium.
typedef G = (String, double, double, double, double);

String rebuild(List<G> glyphs) => const LineRebuilder().rebuild(
  glyphs.map((g) => g.$1).join(),
  [for (final g in glyphs) GlyphBox(g.$2, g.$3, g.$4, g.$5)],
);

void main() {
  // Boxes below were captured from a Chrome-generated PDF (A5, 14pt).

  test('lam-alef ligature emitted in wrong order is fixed by position', () {
    // PDFium stream: ل ل ط ا ل ب  (the ligature halves swapped)
    final out = rebuild([
      ('ل', 330.4, 262.3, 333.5, 251.5),
      ('ل', 325.8, 262.3, 330.7, 251.5),
      ('ط', 314.3, 262.3, 326.1, 251.5),
      ('ا', 306.7, 262.3, 310.6, 251.3),
      ('ل', 310.6, 262.3, 314.6, 251.3),
      ('ب', 293.8, 256.1, 305.0, 249.1),
      (' ', 282.7, 251.5, 282.7, 251.5),
      ('ف', 282.6, 260.5, 288.4, 251.5),
      ('ي', 272.0, 255.0, 282.9, 248.1),
    ]);
    expect(out, 'للطلاب في');
  });

  test('comma emitted on its own line joins the line it sits on', () {
    final out = rebuild([
      ('ع', 259.1, 258.9, 266.2, 251.5),
      ('ا', 256.3, 262.3, 259.4, 251.5),
      ('م', 247.3, 256.7, 253.9, 248.1),
      (' ', 245.1, 251.5, 245.1, 251.5),
      ('،', 211.8, 254.9, 213.8, 251.5),
      ('2', 215.4, 260.9, 221.0, 251.5),
      ('0', 222.3, 260.9, 228.3, 251.3),
      ('2', 229.4, 260.9, 235.0, 251.5),
      ('4', 236.1, 260.9, 241.7, 251.5),
      (' ', 205.0, 251.5, 205.0, 251.5),
      ('ث', 195.9, 260.0, 205.1, 251.5),
      ('م', 189.0, 256.7, 195.6, 248.1),
    ]);
    expect(out, 'عام 2024، ثم');
  });

  test('diacritics split onto their own PDFium line are reattached', () {
    // "الرَّحِيمِ." where PDFium put "ِم" on a separate line first.
    final out = rebuild([
      ('.', 194.5, 500.4, 196.1, 498.8),
      ('\n', 0, 0, 0, 0),
      ('ِ', 198.7, 494.6, 200.7, 493.0),
      ('م', 196.7, 494.6, 198.7, 493.0),
      ('\n', 0, 0, 0, 0),
      ('ا', 232.5, 509.8, 233.8, 499.0),
      ('ل', 226.8, 509.8, 229.9, 499.0),
      ('َ', 221.5, 502.8, 224.3, 495.6),
      ('ّ', 218.6, 502.8, 221.5, 495.6),
      ('ر', 224.3, 502.8, 227.1, 495.6),
      ('ِ', 210.4, 504.6, 214.3, 499.0),
      ('ح', 214.3, 504.6, 218.2, 499.0),
      ('ي', 206.2, 503.1, 210.7, 496.9),
    ]);
    // The trailing "مِ" has a squashed box, so no reliable gap: the
    // normalizer's orphan-letter pass joins it if a space slips in.
    expect(out.replaceAll(' ', ''), 'الرَّحِيمِ.');
    expect(out.startsWith('الرَّحِي'), isTrue);
  });

  test('Latin lines keep PDFium order and spaces', () {
    final out = rebuild([
      ('H', 10, 20, 16, 10),
      ('i', 16, 20, 18, 10),
      (' ', 18, 10, 18, 10),
      ('y', 21, 20, 26, 8),
      ('o', 26, 20, 31, 10),
      ('u', 31, 20, 36, 10),
      ('\r', 0, 0, 0, 0),
      ('\n', 0, 0, 0, 0),
      ('N', 10, 5, 16, -5),
      ('e', 16, 5, 21, -5),
      ('x', 21, 5, 26, -5),
      ('t', 26, 5, 30, -5),
    ]);
    expect(out, 'Hi you\nNext');
  });

  test('lines far apart vertically stay separate', () {
    final out = rebuild([
      ('ب', 100, 20, 110, 10),
      ('ا', 95, 22, 99, 10),
      ('ب', 85, 20, 94, 10),
      ('\n', 0, 0, 0, 0),
      ('ب', 100, 0, 110, -10),
      ('ا', 95, 2, 99, -10),
      ('ب', 85, 0, 94, -10),
    ]);
    expect(out, 'باب\nباب');
  });
}
