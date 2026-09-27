import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:pdfrx/pdfrx.dart';

import '../../core/errors.dart';
import '../../domain/repositories/pdf_text_source.dart';
import '../../domain/text/line_rebuilder.dart';

/// Extracts page text with PDFium (via pdfrx) and renders page 1 as cover.
class PdfrxTextSource implements PdfTextSource {
  const PdfrxTextSource();

  static const _coverWidth = 360;

  @override
  Future<PdfExtraction> extract(
    String path, {
    void Function(int done, int total)? onProgress,
  }) async {
    final PdfDocument doc;
    try {
      doc = await PdfDocument.openFile(path);
    } on PdfPasswordException catch (e) {
      throw AppException(AppErrorKind.passwordProtected, e.message);
    } on PdfException catch (e) {
      throw AppException(AppErrorKind.corruptPdf, e.message);
    } catch (e) {
      throw AppException(AppErrorKind.corruptPdf, '$e');
    }

    try {
      final pages = doc.pages;
      if (pages.isEmpty) {
        throw const AppException(AppErrorKind.corruptPdf, 'no pages');
      }
      final texts = <String>[];
      for (var i = 0; i < pages.length; i++) {
        texts.add(await _pageText(pages[i]));
        onProgress?.call(i + 1, pages.length);
      }
      return PdfExtraction(pages: texts, coverPng: await _cover(pages.first));
    } finally {
      await doc.dispose();
    }
  }

  /// Raw PDFium characters + boxes, re-assembled into lines by
  /// [LineRebuilder] (fixes Arabic diacritics, ligatures and spacing).
  /// A page that cannot be read yields '' and is flagged as "no text".
  Future<String> _pageText(PdfPage page) async {
    try {
      final raw = await page.loadText();
      if (raw == null) return '';
      return pageTextFromRaw(raw);
    } catch (_) {
      return '';
    }
  }

  Future<Uint8List?> _cover(PdfPage page) async {
    try {
      final w = _coverWidth;
      final h = (page.height / page.width * w).round();
      final image = await page.render(
        fullWidth: w.toDouble(),
        fullHeight: h.toDouble(),
        backgroundColor: 0xFFFFFFFF,
      );
      if (image == null) return null;
      try {
        final pic = img.Image.fromBytes(
          width: image.width,
          height: image.height,
          bytes: image.pixels.buffer,
          numChannels: 4,
          order: img.ChannelOrder.bgra,
        );
        return img.encodePng(pic, level: 6);
      } finally {
        image.dispose();
      }
    } catch (_) {
      return null; // A missing cover is not worth failing the import.
    }
  }
}

/// Shared with tool/inspect_pdf.dart.
String pageTextFromRaw(PdfPageRawText raw) {
  try {
    return const LineRebuilder().rebuild(raw.fullText, [
      for (final r in raw.charRects) GlyphBox(r.left, r.top, r.right, r.bottom),
    ]);
  } catch (_) {
    return raw.fullText;
  }
}
