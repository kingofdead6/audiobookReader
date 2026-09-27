import 'dart:math' as math;

import 'language_detector.dart';

/// A character's box on the page in PDF coordinates (y grows upwards, so
/// `top > bottom`).
class GlyphBox {
  const GlyphBox(this.left, this.top, this.right, this.bottom);
  final double left;
  final double top;
  final double right;
  final double bottom;

  double get width => right - left;
  double get height => top - bottom;
  double get centerX => (left + right) / 2;
}

/// Rebuilds reading-order lines from PDFium's character stream using the
/// character boxes.
///
/// PDFium's own line detection breaks Arabic badly: diacritics above or
/// below the baseline become separate "lines", lam-alef ligatures come out
/// reversed, punctuation lands on the wrong line and word spaces go
/// missing. This class:
///  * assigns every character to a line by baseline proximity; diacritics
///    and squashed boxes follow the previous glyph in the stream,
///  * attaches diacritics to the letter they touch,
///  * orders right-to-left lines by x position (right to left) while keeping
///    Latin/number runs left-to-right,
///  * uses PDFium's generated spaces only as "word ends after this glyph"
///    hints, and adds spaces for word-sized gaps PDFium missed.
///
/// Left-to-right lines keep PDFium's order, which is reliable for Latin text.
/// Only the last few lines are candidates when placing a character, so text
/// in separate columns is not merged.
class LineRebuilder {
  const LineRebuilder();

  static const _recentLines = 4;

  String rebuild(String text, List<GlyphBox> boxes) {
    assert(text.length == boxes.length);
    final em = _typicalLetterHeight(text, boxes);
    final lines = <_Line>[];
    _Line? last;
    var prevWasMark = false;

    for (var i = 0; i < text.length; i++) {
      final c = text.codeUnitAt(i);
      if (c == 0x0A || c == 0x0D) continue; // PDFium's own line breaks
      final g = _Glyph(c, boxes[i]);

      if (c == 0x20) {
        // Generated spaces have unreliable positions; they only tell us a
        // word ends after the previous glyph in the stream.
        last?.glyphs.lastOrNull?.spaceAfter = true;
        continue;
      }

      final line = _findLine(lines, last, g, em, prevWasMark);
      prevWasMark = isMark(c);
      if (line != null) {
        line.add(g);
        last = line;
      } else {
        last = _Line()..add(g);
        lines.add(last);
      }
    }

    return lines
        .map((l) => _render(l, em))
        .where((l) => l.trim().isNotEmpty)
        .join('\n');
  }

  /// Median height of letters on the page: the font-size yardstick for
  /// line membership and word gaps.
  static double _typicalLetterHeight(String text, List<GlyphBox> boxes) {
    final hs = <double>[
      for (var i = 0; i < text.length; i++)
        if ((LanguageDetector.isArabicLetter(text.codeUnitAt(i)) ||
                LanguageDetector.isLatinLetter(text.codeUnitAt(i))) &&
            boxes[i].height > 0)
          boxes[i].height,
    ]..sort();
    return hs.isEmpty ? 10 : hs[hs.length ~/ 2];
  }

  _Line? _findLine(
    List<_Line> lines,
    _Line? last,
    _Glyph g,
    double em,
    bool prevWasMark,
  ) {
    final arabic = LanguageDetector.isArabicLetter(g.code);

    // Diacritics, and Arabic letters whose boxes the producer squashed or
    // shifted, follow the glyph before them in the stream.
    if (last != null) {
      final h = math.max(last.height, em);
      final attached = isMark(g.code) || (arabic && g.box.height < h * 0.4);
      if (attached && (g.box.bottom - last.baseline).abs() <= 1.5 * h) {
        return last;
      }
    }

    _Line? best;
    var bestDist = double.infinity;
    for (
      var k = lines.length - 1;
      k >= 0 && k >= lines.length - _recentLines;
      k--
    ) {
      final line = lines[k];
      final h = math.max(line.height, em);
      // Far away horizontally: another column. The stream-adjacent line is
      // exempt because PDFium jumps around inside RTL lines.
      if (!identical(line, last) &&
          (g.box.left > line.maxX + 15 * em ||
              g.box.right < line.minX - 15 * em)) {
        continue;
      }
      final dist = (g.box.bottom - line.baseline).abs();
      if (dist <= 0.45 * h && dist < bestDist) {
        best = line;
        bestDist = dist;
      }
    }
    if (best != null) return best;

    // A letter right after diacritics belongs to the same shaped cluster,
    // even when its box was shifted.
    if (last != null && arabic && prevWasMark) {
      final h = math.max(last.height, em);
      if ((g.box.bottom - last.baseline).abs() <= 1.5 * h &&
          g.box.left <= last.maxX + 2 * em &&
          g.box.right >= last.minX - 2 * em) {
        return last;
      }
    }
    return null;
  }

  String _render(_Line line, double em) {
    var arabic = 0;
    var latin = 0;
    for (final g in line.glyphs) {
      if (LanguageDetector.isArabicLetter(g.code)) arabic++;
      if (LanguageDetector.isLatinLetter(g.code)) latin++;
    }
    if (arabic <= latin) {
      final b = StringBuffer();
      for (final g in line.glyphs) {
        b.writeCharCode(g.code);
        if (g.spaceAfter) b.write(' ');
      }
      return _squash(b.toString());
    }
    return _renderRtl(line, em);
  }

  String _renderRtl(_Line line, double em) {
    final clusters = _clusters(line.glyphs);

    // Visual order (left to right); stable for ties.
    final indexed = clusters.indexed.toList()
      ..sort((a, b) {
        final c = a.$2.centerX.compareTo(b.$2.centerX);
        return c != 0 ? c : a.$1.compareTo(b.$1);
      });
    final rev = indexed.map((e) => e.$2).toList().reversed.toList();

    // Logical order = reversed visual order, except LTR runs (Latin,
    // digits), which read left to right.
    final logical = <_Cluster>[];
    var i = 0;
    while (i < rev.length) {
      if (rev[i].isStrongLtr) {
        var k = i;
        var lastStrong = i;
        while (k < rev.length && !rev[k].hasArabic) {
          if (rev[k].isStrongLtr) lastStrong = k;
          k++;
        }
        logical.addAll(rev.sublist(i, lastStrong + 1).reversed);
        i = lastStrong + 1;
      } else {
        logical.add(rev[i]);
        i++;
      }
    }

    final out = StringBuffer();
    for (var j = 0; j < logical.length; j++) {
      final cur = logical[j];
      out.write(cur.text);
      if (j + 1 == logical.length) break;
      final next = logical[j + 1];
      final gap = cur.left > next.right
          ? cur.left - next.right
          : next.left - cur.right;
      if (cur.spaceAfter ||
          (gap > 0.45 * em && (cur.reliable(em) || next.reliable(em)))) {
        out.write(' ');
      }
    }
    return _squash(out.toString())
        .replaceAllMapped(_spaceBeforePunct, (m) => m[1]!);
  }

  static final _spaceBeforePunct = RegExp(r' +([،؛؟.!:,;)\]»])');

  static String _squash(String s) => s.replaceAll(RegExp(' {2,}'), ' ').trim();

  /// Groups each base character with its diacritics. A run of marks joins
  /// the neighbouring base (in stream order) whose box touches one of the
  /// marks, else the previous base.
  List<_Cluster> _clusters(List<_Glyph> glyphs) {
    final clusters = <_Cluster>[];
    final pending = <_Glyph>[];

    bool touches(_Glyph m, GlyphBox b) =>
        m.box.left <= b.right + 0.3 && m.box.right >= b.left - 0.3;

    for (final g in glyphs) {
      if (isMark(g.code)) {
        pending.add(g);
        continue;
      }
      final cluster = _Cluster(g);
      if (pending.isNotEmpty) {
        final prev = clusters.lastOrNull;
        final touchesNext = pending.any((m) => touches(m, g.box));
        final touchesPrev =
            prev != null && pending.any((m) => touches(m, prev.base.box));
        final target = (touchesNext && !touchesPrev) || prev == null
            ? cluster
            : prev;
        target.marks.addAll(pending);
        pending.clear();
      }
      clusters.add(cluster);
    }
    if (pending.isNotEmpty) {
      if (clusters.isEmpty) {
        // Only marks on the line: keep them as a pseudo-cluster.
        clusters.add(_Cluster(pending.first)..marks.addAll(pending.skip(1)));
      } else {
        clusters.last.marks.addAll(pending);
      }
    }

    // Lam-alef ligature boxes that coincide exactly: force lam first.
    for (var i = 0; i + 1 < clusters.length; i++) {
      final a = clusters[i].base;
      final b = clusters[i + 1].base;
      if (_isAlef(a.code) &&
          b.code == 0x0644 &&
          (a.box.left - b.box.left).abs() < 0.01 &&
          (a.box.right - b.box.right).abs() < 0.01) {
        final t = clusters[i];
        clusters[i] = clusters[i + 1];
        clusters[i + 1] = t;
      }
    }
    return clusters;
  }

  static bool _isAlef(int c) =>
      c == 0x0627 || c == 0x0623 || c == 0x0625 || c == 0x0622;

  /// Arabic combining marks (harakat, shadda, sukun, superscript alef,
  /// Quranic marks).
  static bool isMark(int c) =>
      (c >= 0x064B && c <= 0x065F) ||
      c == 0x0670 ||
      (c >= 0x06D6 && c <= 0x06ED) ||
      (c >= 0x0610 && c <= 0x061A);
}

class _Glyph {
  _Glyph(this.code, this.box);
  final int code;
  final GlyphBox box;

  /// PDFium emitted a space right after this glyph.
  bool spaceAfter = false;
}

class _Line {
  final glyphs = <_Glyph>[];
  final _bottoms = <double>[];
  double _height = 0;
  double minX = double.infinity;
  double maxX = double.negativeInfinity;

  double get height => _height > 0 ? _height : 10;

  /// Median bottom of full-size glyphs.
  double get baseline {
    if (_bottoms.isEmpty) return glyphs.first.box.bottom;
    final s = List.of(_bottoms)..sort();
    return s[s.length ~/ 2];
  }

  void add(_Glyph g) {
    glyphs.add(g);
    minX = math.min(minX, g.box.left);
    maxX = math.max(maxX, g.box.right);
    final h = g.box.height;
    if (!LineRebuilder.isMark(g.code) && (_height == 0 || h >= _height * 0.4)) {
      _bottoms.add(g.box.bottom);
      _height = math.max(_height, h);
    }
  }
}

class _Cluster {
  _Cluster(this.base);

  final _Glyph base;
  final marks = <_Glyph>[];

  Iterable<_Glyph> get _all => [base, ...marks];

  double get left => _all.map((g) => g.box.left).reduce(math.min);
  double get right => _all.map((g) => g.box.right).reduce(math.max);

  /// The base letter decides order; marks may be drawn off-centre.
  double get centerX => base.box.centerX;

  String get text => String.fromCharCodes(_all.map((g) => g.code));

  /// A space followed one of this cluster's glyphs in the stream.
  bool get spaceAfter => _all.any((g) => g.spaceAfter);

  /// False for clusters whose boxes the producer squashed (common with
  /// diacritics); their gaps say nothing about word boundaries.
  bool reliable(double em) => marks.isEmpty && base.box.height >= em * 0.4;

  bool get hasArabic =>
      _all.any((g) => LanguageDetector.isArabicLetter(g.code));

  bool get isStrongLtr {
    final c = base.code;
    return LanguageDetector.isLatinLetter(c) ||
        (c >= 0x30 && c <= 0x39) ||
        (c >= 0x0660 && c <= 0x0669) ||
        (c >= 0x06F0 && c <= 0x06F9);
  }
}
