import '../entities/book.dart';
import '../entities/page_content.dart';
import '../entities/sentence.dart';

/// Page-level metadata without the sentences, for navigation.
class PageInfo {
  const PageInfo({
    required this.pageIndex,
    required this.hasText,
    required this.firstGlobal,
    required this.sentenceCount,
  });

  final int pageIndex;
  final bool hasText;
  final int firstGlobal;
  final int sentenceCount;
}

abstract interface class BookRepository {
  Stream<List<Book>> watchBooks();
  Stream<Book?> watchBook(int id);
  Future<Book?> getBook(int id);
  Future<Book?> findByHash(String fileHash);

  /// Stores the book and its extracted text in one transaction.
  Future<int> insertBook({
    required String title,
    required String fileHash,
    required String filePath,
    required String? coverPath,
    required List<PageContent> pages,
  });

  Future<List<PageInfo>> pageInfos(int bookId);
  Future<PageContent> page(int bookId, int pageIndex);
  Future<List<Sentence>> sentences(int bookId, int fromGlobal, int count);

  Future<void> savePosition(int bookId, int globalIndex);
  Future<void> markOpened(int bookId);

  /// Deletes DB rows; the caller removes files.
  Future<void> deleteBook(int bookId);
}
