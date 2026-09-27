import 'dart:typed_data';

/// Raw text of every page plus a cover image. Implemented with pdfrx today;
/// an OCR-backed source can implement the same interface later.
class PdfExtraction {
  const PdfExtraction({required this.pages, this.coverPng});

  /// Raw (uncleaned) text per page, in page order.
  final List<String> pages;
  final Uint8List? coverPng;
}

abstract interface class PdfTextSource {
  /// Throws `AppException` with `corruptPdf` or `passwordProtected`.
  Future<PdfExtraction> extract(
    String path, {
    void Function(int done, int total)? onProgress,
  });
}
