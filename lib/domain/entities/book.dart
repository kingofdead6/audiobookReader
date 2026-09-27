/// A book in the library.
class Book {
  const Book({
    required this.id,
    required this.title,
    required this.filePath,
    required this.coverPath,
    required this.pageCount,
    required this.emptyPageCount,
    required this.sentenceCount,
    required this.position,
    required this.createdAt,
    this.lastOpenedAt,
  });

  final int id;
  final String title;

  /// Copy of the PDF inside the app's documents directory.
  final String filePath;
  final String? coverPath;
  final int pageCount;

  /// Pages without a text layer (scanned or blank).
  final int emptyPageCount;
  final int sentenceCount;
  final ReadingPosition position;
  final DateTime createdAt;
  final DateTime? lastOpenedAt;

  /// 0.0–1.0 based on the sentence reached.
  double get progress => sentenceCount <= 1
      ? 0
      : (position.globalIndex / (sentenceCount - 1)).clamp(0.0, 1.0);
}

/// Where the reader stopped. [globalIndex] is authoritative; page and
/// sentence-in-page are stored for display and for jumping back quickly.
class ReadingPosition {
  const ReadingPosition({
    required this.pageIndex,
    required this.sentenceInPage,
    required this.globalIndex,
  });

  static const start = ReadingPosition(
    pageIndex: 0,
    sentenceInPage: 0,
    globalIndex: 0,
  );

  final int pageIndex;
  final int sentenceInPage;
  final int globalIndex;
}
