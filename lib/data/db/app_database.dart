import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('BookRow')
class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();

  /// SHA-256 of the file, used to detect re-imports of the same PDF.
  TextColumn get fileHash => text().unique()();
  TextColumn get filePath => text()();
  TextColumn get coverPath => text().nullable()();
  IntColumn get pageCount => integer()();
  IntColumn get emptyPageCount => integer().withDefault(const Constant(0))();
  IntColumn get sentenceCount => integer().withDefault(const Constant(0))();
  IntColumn get posPage => integer().withDefault(const Constant(0))();
  IntColumn get posSentence => integer().withDefault(const Constant(0))();
  IntColumn get posGlobal => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastOpenedAt => dateTime().nullable()();
}

/// One row per PDF page; the cached extraction result.
@DataClassName('PageRow')
class Pages extends Table {
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get pageIndex => integer()();
  BoolColumn get hasText => boolean()();

  /// Global index of the first sentence on this page (or of the next
  /// sentence, for empty pages). Lets the player map page -> sentence fast.
  IntColumn get firstGlobal => integer()();
  IntColumn get sentenceCount => integer()();

  @override
  Set<Column> get primaryKey => {bookId, pageIndex};
}

@TableIndex(name: 'sentences_book_global', columns: {#bookId, #globalIndex})
@TableIndex(name: 'sentences_book_page', columns: {#bookId, #pageIndex})
@DataClassName('SentenceRow')
class Sentences extends Table {
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get globalIndex => integer()();
  IntColumn get pageIndex => integer()();
  IntColumn get indexInPage => integer()();
  IntColumn get paragraph => integer()();

  /// `Lang.index`.
  IntColumn get lang => integer()();
  TextColumn get body => text()();

  @override
  Set<Column> get primaryKey => {bookId, globalIndex};
}

/// Simple key/value store for user settings.
@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Books, Pages, Sentences, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'qari'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
