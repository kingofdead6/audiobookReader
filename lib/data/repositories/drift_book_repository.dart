import 'package:drift/drift.dart';

import '../../domain/entities/book.dart';
import '../../domain/entities/lang.dart';
import '../../domain/entities/page_content.dart';
import '../../domain/entities/sentence.dart';
import '../../domain/repositories/book_repository.dart';
import '../db/app_database.dart';

class DriftBookRepository implements BookRepository {
  DriftBookRepository(this._db);

  final AppDatabase _db;

  Book _toBook(BookRow r) => Book(
    id: r.id,
    title: r.title,
    filePath: r.filePath,
    coverPath: r.coverPath,
    pageCount: r.pageCount,
    emptyPageCount: r.emptyPageCount,
    sentenceCount: r.sentenceCount,
    position: ReadingPosition(
      pageIndex: r.posPage,
      sentenceInPage: r.posSentence,
      globalIndex: r.posGlobal,
    ),
    createdAt: r.createdAt,
    lastOpenedAt: r.lastOpenedAt,
  );

  Sentence _toSentence(SentenceRow r) => Sentence(
    pageIndex: r.pageIndex,
    indexInPage: r.indexInPage,
    globalIndex: r.globalIndex,
    paragraph: r.paragraph,
    text: r.body,
    lang: Lang.fromCode(r.lang),
  );

  @override
  Stream<List<Book>> watchBooks() {
    final q = _db.select(_db.books)
      ..orderBy([
        (b) => OrderingTerm(
          expression: coalesce([b.lastOpenedAt, b.createdAt]),
          mode: OrderingMode.desc,
        ),
      ]);
    return q.watch().map((rows) => rows.map(_toBook).toList());
  }

  @override
  Stream<Book?> watchBook(int id) =>
      (_db.select(_db.books)..where((b) => b.id.equals(id)))
          .watchSingleOrNull()
          .map((r) => r == null ? null : _toBook(r));

  @override
  Future<Book?> getBook(int id) async {
    final r = await (_db.select(
      _db.books,
    )..where((b) => b.id.equals(id))).getSingleOrNull();
    return r == null ? null : _toBook(r);
  }

  @override
  Future<Book?> findByHash(String fileHash) async {
    final r = await (_db.select(
      _db.books,
    )..where((b) => b.fileHash.equals(fileHash))).getSingleOrNull();
    return r == null ? null : _toBook(r);
  }

  @override
  Future<int> insertBook({
    required String title,
    required String fileHash,
    required String filePath,
    required String? coverPath,
    required List<PageContent> pages,
  }) {
    return _db.transaction(() async {
      final total = pages.fold<int>(0, (n, p) => n + p.sentences.length);
      final id = await _db
          .into(_db.books)
          .insert(
            BooksCompanion.insert(
              title: title,
              fileHash: fileHash,
              filePath: filePath,
              coverPath: Value(coverPath),
              pageCount: pages.length,
              emptyPageCount: Value(pages.where((p) => !p.hasText).length),
              sentenceCount: Value(total),
              createdAt: DateTime.now(),
            ),
          );

      await _db.batch((b) {
        var nextGlobal = 0;
        for (final p in pages) {
          final first = p.sentences.isEmpty
              ? nextGlobal
              : p.sentences.first.globalIndex;
          nextGlobal = first + p.sentences.length;
          b.insert(
            _db.pages,
            PagesCompanion.insert(
              bookId: id,
              pageIndex: p.pageIndex,
              hasText: p.hasText,
              firstGlobal: first,
              sentenceCount: p.sentences.length,
            ),
          );
          b.insertAll(_db.sentences, [
            for (final s in p.sentences)
              SentencesCompanion.insert(
                bookId: id,
                globalIndex: s.globalIndex,
                pageIndex: s.pageIndex,
                indexInPage: s.indexInPage,
                paragraph: s.paragraph,
                lang: s.lang.index,
                body: s.text,
              ),
          ]);
        }
      });
      return id;
    });
  }

  @override
  Future<List<PageInfo>> pageInfos(int bookId) async {
    final rows =
        await (_db.select(_db.pages)
              ..where((p) => p.bookId.equals(bookId))
              ..orderBy([(p) => OrderingTerm.asc(p.pageIndex)]))
            .get();
    return [
      for (final r in rows)
        PageInfo(
          pageIndex: r.pageIndex,
          hasText: r.hasText,
          firstGlobal: r.firstGlobal,
          sentenceCount: r.sentenceCount,
        ),
    ];
  }

  @override
  Future<PageContent> page(int bookId, int pageIndex) async {
    final info =
        await (_db.select(_db.pages)..where(
              (p) => p.bookId.equals(bookId) & p.pageIndex.equals(pageIndex),
            ))
            .getSingle();
    final rows =
        await (_db.select(_db.sentences)
              ..where(
                (s) => s.bookId.equals(bookId) & s.pageIndex.equals(pageIndex),
              )
              ..orderBy([(s) => OrderingTerm.asc(s.globalIndex)]))
            .get();
    return PageContent(
      pageIndex: pageIndex,
      hasText: info.hasText,
      sentences: rows.map(_toSentence).toList(),
    );
  }

  @override
  Future<List<Sentence>> sentences(
    int bookId,
    int fromGlobal,
    int count,
  ) async {
    final rows =
        await (_db.select(_db.sentences)
              ..where(
                (s) =>
                    s.bookId.equals(bookId) &
                    s.globalIndex.isBetweenValues(
                      fromGlobal,
                      fromGlobal + count - 1,
                    ),
              )
              ..orderBy([(s) => OrderingTerm.asc(s.globalIndex)]))
            .get();
    return rows.map(_toSentence).toList();
  }

  @override
  Future<void> savePosition(int bookId, int globalIndex) async {
    final s =
        await (_db.select(_db.sentences)..where(
              (s) =>
                  s.bookId.equals(bookId) & s.globalIndex.equals(globalIndex),
            ))
            .getSingleOrNull();
    if (s == null) return;
    await (_db.update(_db.books)..where((b) => b.id.equals(bookId))).write(
      BooksCompanion(
        posGlobal: Value(globalIndex),
        posPage: Value(s.pageIndex),
        posSentence: Value(s.indexInPage),
      ),
    );
  }

  @override
  Future<void> markOpened(int bookId) =>
      (_db.update(_db.books)..where((b) => b.id.equals(bookId))).write(
        BooksCompanion(lastOpenedAt: Value(DateTime.now())),
      );

  @override
  Future<void> deleteBook(int bookId) => _db.transaction(() async {
    await (_db.delete(
      _db.sentences,
    )..where((s) => s.bookId.equals(bookId))).go();
    await (_db.delete(_db.pages)..where((p) => p.bookId.equals(bookId))).go();
    await (_db.delete(_db.books)..where((b) => b.id.equals(bookId))).go();
  });
}
