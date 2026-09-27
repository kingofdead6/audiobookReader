import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../../core/errors.dart';
import '../entities/page_content.dart';
import '../repositories/book_repository.dart';
import '../repositories/pdf_text_source.dart';
import '../text/book_text_builder.dart';

enum ImportStage { copying, extracting, processing, saving }

class ImportProgress {
  const ImportProgress(this.stage, [this.done = 0, this.total = 0]);
  final ImportStage stage;
  final int done;
  final int total;
}

/// PDF file -> copy into app storage -> extract -> clean/split (in an
/// isolate) -> cover -> one DB transaction. Re-opening a book afterwards
/// reads only the cached text from the DB.
class ImportBook {
  ImportBook({
    required this.books,
    required this.source,
    required this.booksDir,
    required this.coversDir,
  });

  final BookRepository books;
  final PdfTextSource source;
  final String booksDir;
  final String coversDir;

  Future<int> call(
    String sourcePath, {
    String? displayName,
    void Function(ImportProgress)? onProgress,
  }) async {
    onProgress?.call(const ImportProgress(ImportStage.copying));
    final hash = await _hashFile(sourcePath);
    final existing = await books.findByHash(hash);
    if (existing != null) {
      throw AppException(AppErrorKind.alreadyImported, existing.title);
    }

    final id = hash.substring(0, 16);
    final pdfPath = p.join(booksDir, '$id.pdf');
    final coverPath = p.join(coversDir, '$id.png');
    try {
      await File(sourcePath).copy(pdfPath);
    } on FileSystemException catch (e) {
      throw _ioError(e);
    }

    try {
      final extraction = await source.extract(
        pdfPath,
        onProgress: (d, t) =>
            onProgress?.call(ImportProgress(ImportStage.extracting, d, t)),
      );

      onProgress?.call(const ImportProgress(ImportStage.processing));
      final raw = extraction.pages;
      final pages = await Isolate.run<List<PageContent>>(
        () => const BookTextBuilder().build(raw),
      );
      if (pages.every((pg) => !pg.hasText)) {
        throw const AppException(AppErrorKind.noTextLayer);
      }

      String? cover;
      if (extraction.coverPng != null) {
        await File(coverPath).writeAsBytes(extraction.coverPng!);
        cover = coverPath;
      }

      onProgress?.call(const ImportProgress(ImportStage.saving));
      return await books.insertBook(
        title: _title(displayName ?? sourcePath),
        fileHash: hash,
        filePath: pdfPath,
        coverPath: cover,
        pages: pages,
      );
    } on FileSystemException catch (e) {
      await _cleanup(pdfPath, coverPath);
      throw _ioError(e);
    } catch (_) {
      await _cleanup(pdfPath, coverPath);
      rethrow;
    }
  }

  static AppException _ioError(FileSystemException e) {
    // ENOSPC = 28 on Linux/Android.
    if (e.osError?.errorCode == 28) {
      return AppException(AppErrorKind.lowStorage, e.message);
    }
    return AppException(AppErrorKind.unknown, '$e');
  }

  static Future<void> _cleanup(String pdf, String cover) async {
    for (final f in [pdf, cover]) {
      try {
        await File(f).delete();
      } catch (_) {}
    }
  }

  static Future<String> _hashFile(String path) async {
    final digest = await sha256.bind(File(path).openRead()).first;
    return digest.toString();
  }

  static String _title(String name) {
    final base = p.basenameWithoutExtension(name);
    return base.replaceAll(RegExp(r'[_]+'), ' ').trim();
  }
}
