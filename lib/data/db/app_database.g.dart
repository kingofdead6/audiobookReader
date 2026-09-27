// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, BookRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileHashMeta = const VerificationMeta(
    'fileHash',
  );
  @override
  late final GeneratedColumn<String> fileHash = GeneratedColumn<String>(
    'file_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverPathMeta = const VerificationMeta(
    'coverPath',
  );
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
    'cover_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emptyPageCountMeta = const VerificationMeta(
    'emptyPageCount',
  );
  @override
  late final GeneratedColumn<int> emptyPageCount = GeneratedColumn<int>(
    'empty_page_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sentenceCountMeta = const VerificationMeta(
    'sentenceCount',
  );
  @override
  late final GeneratedColumn<int> sentenceCount = GeneratedColumn<int>(
    'sentence_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _posPageMeta = const VerificationMeta(
    'posPage',
  );
  @override
  late final GeneratedColumn<int> posPage = GeneratedColumn<int>(
    'pos_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _posSentenceMeta = const VerificationMeta(
    'posSentence',
  );
  @override
  late final GeneratedColumn<int> posSentence = GeneratedColumn<int>(
    'pos_sentence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _posGlobalMeta = const VerificationMeta(
    'posGlobal',
  );
  @override
  late final GeneratedColumn<int> posGlobal = GeneratedColumn<int>(
    'pos_global',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastOpenedAtMeta = const VerificationMeta(
    'lastOpenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastOpenedAt = GeneratedColumn<DateTime>(
    'last_opened_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    fileHash,
    filePath,
    coverPath,
    pageCount,
    emptyPageCount,
    sentenceCount,
    posPage,
    posSentence,
    posGlobal,
    createdAt,
    lastOpenedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('file_hash')) {
      context.handle(
        _fileHashMeta,
        fileHash.isAcceptableOrUnknown(data['file_hash']!, _fileHashMeta),
      );
    } else if (isInserting) {
      context.missing(_fileHashMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('cover_path')) {
      context.handle(
        _coverPathMeta,
        coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta),
      );
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    } else if (isInserting) {
      context.missing(_pageCountMeta);
    }
    if (data.containsKey('empty_page_count')) {
      context.handle(
        _emptyPageCountMeta,
        emptyPageCount.isAcceptableOrUnknown(
          data['empty_page_count']!,
          _emptyPageCountMeta,
        ),
      );
    }
    if (data.containsKey('sentence_count')) {
      context.handle(
        _sentenceCountMeta,
        sentenceCount.isAcceptableOrUnknown(
          data['sentence_count']!,
          _sentenceCountMeta,
        ),
      );
    }
    if (data.containsKey('pos_page')) {
      context.handle(
        _posPageMeta,
        posPage.isAcceptableOrUnknown(data['pos_page']!, _posPageMeta),
      );
    }
    if (data.containsKey('pos_sentence')) {
      context.handle(
        _posSentenceMeta,
        posSentence.isAcceptableOrUnknown(
          data['pos_sentence']!,
          _posSentenceMeta,
        ),
      );
    }
    if (data.containsKey('pos_global')) {
      context.handle(
        _posGlobalMeta,
        posGlobal.isAcceptableOrUnknown(data['pos_global']!, _posGlobalMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_opened_at')) {
      context.handle(
        _lastOpenedAtMeta,
        lastOpenedAt.isAcceptableOrUnknown(
          data['last_opened_at']!,
          _lastOpenedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      fileHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_hash'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      coverPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path'],
      ),
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      )!,
      emptyPageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}empty_page_count'],
      )!,
      sentenceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sentence_count'],
      )!,
      posPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pos_page'],
      )!,
      posSentence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pos_sentence'],
      )!,
      posGlobal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pos_global'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastOpenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_opened_at'],
      ),
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class BookRow extends DataClass implements Insertable<BookRow> {
  final int id;
  final String title;

  /// SHA-256 of the file, used to detect re-imports of the same PDF.
  final String fileHash;
  final String filePath;
  final String? coverPath;
  final int pageCount;
  final int emptyPageCount;
  final int sentenceCount;
  final int posPage;
  final int posSentence;
  final int posGlobal;
  final DateTime createdAt;
  final DateTime? lastOpenedAt;
  const BookRow({
    required this.id,
    required this.title,
    required this.fileHash,
    required this.filePath,
    this.coverPath,
    required this.pageCount,
    required this.emptyPageCount,
    required this.sentenceCount,
    required this.posPage,
    required this.posSentence,
    required this.posGlobal,
    required this.createdAt,
    this.lastOpenedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['file_hash'] = Variable<String>(fileHash);
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    map['page_count'] = Variable<int>(pageCount);
    map['empty_page_count'] = Variable<int>(emptyPageCount);
    map['sentence_count'] = Variable<int>(sentenceCount);
    map['pos_page'] = Variable<int>(posPage);
    map['pos_sentence'] = Variable<int>(posSentence);
    map['pos_global'] = Variable<int>(posGlobal);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastOpenedAt != null) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt);
    }
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      fileHash: Value(fileHash),
      filePath: Value(filePath),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      pageCount: Value(pageCount),
      emptyPageCount: Value(emptyPageCount),
      sentenceCount: Value(sentenceCount),
      posPage: Value(posPage),
      posSentence: Value(posSentence),
      posGlobal: Value(posGlobal),
      createdAt: Value(createdAt),
      lastOpenedAt: lastOpenedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOpenedAt),
    );
  }

  factory BookRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      fileHash: serializer.fromJson<String>(json['fileHash']),
      filePath: serializer.fromJson<String>(json['filePath']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      pageCount: serializer.fromJson<int>(json['pageCount']),
      emptyPageCount: serializer.fromJson<int>(json['emptyPageCount']),
      sentenceCount: serializer.fromJson<int>(json['sentenceCount']),
      posPage: serializer.fromJson<int>(json['posPage']),
      posSentence: serializer.fromJson<int>(json['posSentence']),
      posGlobal: serializer.fromJson<int>(json['posGlobal']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastOpenedAt: serializer.fromJson<DateTime?>(json['lastOpenedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'fileHash': serializer.toJson<String>(fileHash),
      'filePath': serializer.toJson<String>(filePath),
      'coverPath': serializer.toJson<String?>(coverPath),
      'pageCount': serializer.toJson<int>(pageCount),
      'emptyPageCount': serializer.toJson<int>(emptyPageCount),
      'sentenceCount': serializer.toJson<int>(sentenceCount),
      'posPage': serializer.toJson<int>(posPage),
      'posSentence': serializer.toJson<int>(posSentence),
      'posGlobal': serializer.toJson<int>(posGlobal),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastOpenedAt': serializer.toJson<DateTime?>(lastOpenedAt),
    };
  }

  BookRow copyWith({
    int? id,
    String? title,
    String? fileHash,
    String? filePath,
    Value<String?> coverPath = const Value.absent(),
    int? pageCount,
    int? emptyPageCount,
    int? sentenceCount,
    int? posPage,
    int? posSentence,
    int? posGlobal,
    DateTime? createdAt,
    Value<DateTime?> lastOpenedAt = const Value.absent(),
  }) => BookRow(
    id: id ?? this.id,
    title: title ?? this.title,
    fileHash: fileHash ?? this.fileHash,
    filePath: filePath ?? this.filePath,
    coverPath: coverPath.present ? coverPath.value : this.coverPath,
    pageCount: pageCount ?? this.pageCount,
    emptyPageCount: emptyPageCount ?? this.emptyPageCount,
    sentenceCount: sentenceCount ?? this.sentenceCount,
    posPage: posPage ?? this.posPage,
    posSentence: posSentence ?? this.posSentence,
    posGlobal: posGlobal ?? this.posGlobal,
    createdAt: createdAt ?? this.createdAt,
    lastOpenedAt: lastOpenedAt.present ? lastOpenedAt.value : this.lastOpenedAt,
  );
  BookRow copyWithCompanion(BooksCompanion data) {
    return BookRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      fileHash: data.fileHash.present ? data.fileHash.value : this.fileHash,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      emptyPageCount: data.emptyPageCount.present
          ? data.emptyPageCount.value
          : this.emptyPageCount,
      sentenceCount: data.sentenceCount.present
          ? data.sentenceCount.value
          : this.sentenceCount,
      posPage: data.posPage.present ? data.posPage.value : this.posPage,
      posSentence: data.posSentence.present
          ? data.posSentence.value
          : this.posSentence,
      posGlobal: data.posGlobal.present ? data.posGlobal.value : this.posGlobal,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastOpenedAt: data.lastOpenedAt.present
          ? data.lastOpenedAt.value
          : this.lastOpenedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('fileHash: $fileHash, ')
          ..write('filePath: $filePath, ')
          ..write('coverPath: $coverPath, ')
          ..write('pageCount: $pageCount, ')
          ..write('emptyPageCount: $emptyPageCount, ')
          ..write('sentenceCount: $sentenceCount, ')
          ..write('posPage: $posPage, ')
          ..write('posSentence: $posSentence, ')
          ..write('posGlobal: $posGlobal, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastOpenedAt: $lastOpenedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    fileHash,
    filePath,
    coverPath,
    pageCount,
    emptyPageCount,
    sentenceCount,
    posPage,
    posSentence,
    posGlobal,
    createdAt,
    lastOpenedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.fileHash == this.fileHash &&
          other.filePath == this.filePath &&
          other.coverPath == this.coverPath &&
          other.pageCount == this.pageCount &&
          other.emptyPageCount == this.emptyPageCount &&
          other.sentenceCount == this.sentenceCount &&
          other.posPage == this.posPage &&
          other.posSentence == this.posSentence &&
          other.posGlobal == this.posGlobal &&
          other.createdAt == this.createdAt &&
          other.lastOpenedAt == this.lastOpenedAt);
}

class BooksCompanion extends UpdateCompanion<BookRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> fileHash;
  final Value<String> filePath;
  final Value<String?> coverPath;
  final Value<int> pageCount;
  final Value<int> emptyPageCount;
  final Value<int> sentenceCount;
  final Value<int> posPage;
  final Value<int> posSentence;
  final Value<int> posGlobal;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastOpenedAt;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.fileHash = const Value.absent(),
    this.filePath = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.emptyPageCount = const Value.absent(),
    this.sentenceCount = const Value.absent(),
    this.posPage = const Value.absent(),
    this.posSentence = const Value.absent(),
    this.posGlobal = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String fileHash,
    required String filePath,
    this.coverPath = const Value.absent(),
    required int pageCount,
    this.emptyPageCount = const Value.absent(),
    this.sentenceCount = const Value.absent(),
    this.posPage = const Value.absent(),
    this.posSentence = const Value.absent(),
    this.posGlobal = const Value.absent(),
    required DateTime createdAt,
    this.lastOpenedAt = const Value.absent(),
  }) : title = Value(title),
       fileHash = Value(fileHash),
       filePath = Value(filePath),
       pageCount = Value(pageCount),
       createdAt = Value(createdAt);
  static Insertable<BookRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? fileHash,
    Expression<String>? filePath,
    Expression<String>? coverPath,
    Expression<int>? pageCount,
    Expression<int>? emptyPageCount,
    Expression<int>? sentenceCount,
    Expression<int>? posPage,
    Expression<int>? posSentence,
    Expression<int>? posGlobal,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastOpenedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (fileHash != null) 'file_hash': fileHash,
      if (filePath != null) 'file_path': filePath,
      if (coverPath != null) 'cover_path': coverPath,
      if (pageCount != null) 'page_count': pageCount,
      if (emptyPageCount != null) 'empty_page_count': emptyPageCount,
      if (sentenceCount != null) 'sentence_count': sentenceCount,
      if (posPage != null) 'pos_page': posPage,
      if (posSentence != null) 'pos_sentence': posSentence,
      if (posGlobal != null) 'pos_global': posGlobal,
      if (createdAt != null) 'created_at': createdAt,
      if (lastOpenedAt != null) 'last_opened_at': lastOpenedAt,
    });
  }

  BooksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? fileHash,
    Value<String>? filePath,
    Value<String?>? coverPath,
    Value<int>? pageCount,
    Value<int>? emptyPageCount,
    Value<int>? sentenceCount,
    Value<int>? posPage,
    Value<int>? posSentence,
    Value<int>? posGlobal,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastOpenedAt,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      fileHash: fileHash ?? this.fileHash,
      filePath: filePath ?? this.filePath,
      coverPath: coverPath ?? this.coverPath,
      pageCount: pageCount ?? this.pageCount,
      emptyPageCount: emptyPageCount ?? this.emptyPageCount,
      sentenceCount: sentenceCount ?? this.sentenceCount,
      posPage: posPage ?? this.posPage,
      posSentence: posSentence ?? this.posSentence,
      posGlobal: posGlobal ?? this.posGlobal,
      createdAt: createdAt ?? this.createdAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (fileHash.present) {
      map['file_hash'] = Variable<String>(fileHash.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (emptyPageCount.present) {
      map['empty_page_count'] = Variable<int>(emptyPageCount.value);
    }
    if (sentenceCount.present) {
      map['sentence_count'] = Variable<int>(sentenceCount.value);
    }
    if (posPage.present) {
      map['pos_page'] = Variable<int>(posPage.value);
    }
    if (posSentence.present) {
      map['pos_sentence'] = Variable<int>(posSentence.value);
    }
    if (posGlobal.present) {
      map['pos_global'] = Variable<int>(posGlobal.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('fileHash: $fileHash, ')
          ..write('filePath: $filePath, ')
          ..write('coverPath: $coverPath, ')
          ..write('pageCount: $pageCount, ')
          ..write('emptyPageCount: $emptyPageCount, ')
          ..write('sentenceCount: $sentenceCount, ')
          ..write('posPage: $posPage, ')
          ..write('posSentence: $posSentence, ')
          ..write('posGlobal: $posGlobal, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastOpenedAt: $lastOpenedAt')
          ..write(')'))
        .toString();
  }
}

class $PagesTable extends Pages with TableInfo<$PagesTable, PageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pageIndexMeta = const VerificationMeta(
    'pageIndex',
  );
  @override
  late final GeneratedColumn<int> pageIndex = GeneratedColumn<int>(
    'page_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hasTextMeta = const VerificationMeta(
    'hasText',
  );
  @override
  late final GeneratedColumn<bool> hasText = GeneratedColumn<bool>(
    'has_text',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_text" IN (0, 1))',
    ),
  );
  static const VerificationMeta _firstGlobalMeta = const VerificationMeta(
    'firstGlobal',
  );
  @override
  late final GeneratedColumn<int> firstGlobal = GeneratedColumn<int>(
    'first_global',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sentenceCountMeta = const VerificationMeta(
    'sentenceCount',
  );
  @override
  late final GeneratedColumn<int> sentenceCount = GeneratedColumn<int>(
    'sentence_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    bookId,
    pageIndex,
    hasText,
    firstGlobal,
    sentenceCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pages';
  @override
  VerificationContext validateIntegrity(
    Insertable<PageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('page_index')) {
      context.handle(
        _pageIndexMeta,
        pageIndex.isAcceptableOrUnknown(data['page_index']!, _pageIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIndexMeta);
    }
    if (data.containsKey('has_text')) {
      context.handle(
        _hasTextMeta,
        hasText.isAcceptableOrUnknown(data['has_text']!, _hasTextMeta),
      );
    } else if (isInserting) {
      context.missing(_hasTextMeta);
    }
    if (data.containsKey('first_global')) {
      context.handle(
        _firstGlobalMeta,
        firstGlobal.isAcceptableOrUnknown(
          data['first_global']!,
          _firstGlobalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstGlobalMeta);
    }
    if (data.containsKey('sentence_count')) {
      context.handle(
        _sentenceCountMeta,
        sentenceCount.isAcceptableOrUnknown(
          data['sentence_count']!,
          _sentenceCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sentenceCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, pageIndex};
  @override
  PageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PageRow(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      pageIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_index'],
      )!,
      hasText: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_text'],
      )!,
      firstGlobal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_global'],
      )!,
      sentenceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sentence_count'],
      )!,
    );
  }

  @override
  $PagesTable createAlias(String alias) {
    return $PagesTable(attachedDatabase, alias);
  }
}

class PageRow extends DataClass implements Insertable<PageRow> {
  final int bookId;
  final int pageIndex;
  final bool hasText;

  /// Global index of the first sentence on this page (or of the next
  /// sentence, for empty pages). Lets the player map page -> sentence fast.
  final int firstGlobal;
  final int sentenceCount;
  const PageRow({
    required this.bookId,
    required this.pageIndex,
    required this.hasText,
    required this.firstGlobal,
    required this.sentenceCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<int>(bookId);
    map['page_index'] = Variable<int>(pageIndex);
    map['has_text'] = Variable<bool>(hasText);
    map['first_global'] = Variable<int>(firstGlobal);
    map['sentence_count'] = Variable<int>(sentenceCount);
    return map;
  }

  PagesCompanion toCompanion(bool nullToAbsent) {
    return PagesCompanion(
      bookId: Value(bookId),
      pageIndex: Value(pageIndex),
      hasText: Value(hasText),
      firstGlobal: Value(firstGlobal),
      sentenceCount: Value(sentenceCount),
    );
  }

  factory PageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PageRow(
      bookId: serializer.fromJson<int>(json['bookId']),
      pageIndex: serializer.fromJson<int>(json['pageIndex']),
      hasText: serializer.fromJson<bool>(json['hasText']),
      firstGlobal: serializer.fromJson<int>(json['firstGlobal']),
      sentenceCount: serializer.fromJson<int>(json['sentenceCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<int>(bookId),
      'pageIndex': serializer.toJson<int>(pageIndex),
      'hasText': serializer.toJson<bool>(hasText),
      'firstGlobal': serializer.toJson<int>(firstGlobal),
      'sentenceCount': serializer.toJson<int>(sentenceCount),
    };
  }

  PageRow copyWith({
    int? bookId,
    int? pageIndex,
    bool? hasText,
    int? firstGlobal,
    int? sentenceCount,
  }) => PageRow(
    bookId: bookId ?? this.bookId,
    pageIndex: pageIndex ?? this.pageIndex,
    hasText: hasText ?? this.hasText,
    firstGlobal: firstGlobal ?? this.firstGlobal,
    sentenceCount: sentenceCount ?? this.sentenceCount,
  );
  PageRow copyWithCompanion(PagesCompanion data) {
    return PageRow(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      pageIndex: data.pageIndex.present ? data.pageIndex.value : this.pageIndex,
      hasText: data.hasText.present ? data.hasText.value : this.hasText,
      firstGlobal: data.firstGlobal.present
          ? data.firstGlobal.value
          : this.firstGlobal,
      sentenceCount: data.sentenceCount.present
          ? data.sentenceCount.value
          : this.sentenceCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PageRow(')
          ..write('bookId: $bookId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('hasText: $hasText, ')
          ..write('firstGlobal: $firstGlobal, ')
          ..write('sentenceCount: $sentenceCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(bookId, pageIndex, hasText, firstGlobal, sentenceCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PageRow &&
          other.bookId == this.bookId &&
          other.pageIndex == this.pageIndex &&
          other.hasText == this.hasText &&
          other.firstGlobal == this.firstGlobal &&
          other.sentenceCount == this.sentenceCount);
}

class PagesCompanion extends UpdateCompanion<PageRow> {
  final Value<int> bookId;
  final Value<int> pageIndex;
  final Value<bool> hasText;
  final Value<int> firstGlobal;
  final Value<int> sentenceCount;
  final Value<int> rowid;
  const PagesCompanion({
    this.bookId = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.hasText = const Value.absent(),
    this.firstGlobal = const Value.absent(),
    this.sentenceCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PagesCompanion.insert({
    required int bookId,
    required int pageIndex,
    required bool hasText,
    required int firstGlobal,
    required int sentenceCount,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       pageIndex = Value(pageIndex),
       hasText = Value(hasText),
       firstGlobal = Value(firstGlobal),
       sentenceCount = Value(sentenceCount);
  static Insertable<PageRow> custom({
    Expression<int>? bookId,
    Expression<int>? pageIndex,
    Expression<bool>? hasText,
    Expression<int>? firstGlobal,
    Expression<int>? sentenceCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (pageIndex != null) 'page_index': pageIndex,
      if (hasText != null) 'has_text': hasText,
      if (firstGlobal != null) 'first_global': firstGlobal,
      if (sentenceCount != null) 'sentence_count': sentenceCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PagesCompanion copyWith({
    Value<int>? bookId,
    Value<int>? pageIndex,
    Value<bool>? hasText,
    Value<int>? firstGlobal,
    Value<int>? sentenceCount,
    Value<int>? rowid,
  }) {
    return PagesCompanion(
      bookId: bookId ?? this.bookId,
      pageIndex: pageIndex ?? this.pageIndex,
      hasText: hasText ?? this.hasText,
      firstGlobal: firstGlobal ?? this.firstGlobal,
      sentenceCount: sentenceCount ?? this.sentenceCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (pageIndex.present) {
      map['page_index'] = Variable<int>(pageIndex.value);
    }
    if (hasText.present) {
      map['has_text'] = Variable<bool>(hasText.value);
    }
    if (firstGlobal.present) {
      map['first_global'] = Variable<int>(firstGlobal.value);
    }
    if (sentenceCount.present) {
      map['sentence_count'] = Variable<int>(sentenceCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagesCompanion(')
          ..write('bookId: $bookId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('hasText: $hasText, ')
          ..write('firstGlobal: $firstGlobal, ')
          ..write('sentenceCount: $sentenceCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SentencesTable extends Sentences
    with TableInfo<$SentencesTable, SentenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SentencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _globalIndexMeta = const VerificationMeta(
    'globalIndex',
  );
  @override
  late final GeneratedColumn<int> globalIndex = GeneratedColumn<int>(
    'global_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageIndexMeta = const VerificationMeta(
    'pageIndex',
  );
  @override
  late final GeneratedColumn<int> pageIndex = GeneratedColumn<int>(
    'page_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _indexInPageMeta = const VerificationMeta(
    'indexInPage',
  );
  @override
  late final GeneratedColumn<int> indexInPage = GeneratedColumn<int>(
    'index_in_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paragraphMeta = const VerificationMeta(
    'paragraph',
  );
  @override
  late final GeneratedColumn<int> paragraph = GeneratedColumn<int>(
    'paragraph',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  @override
  late final GeneratedColumn<int> lang = GeneratedColumn<int>(
    'lang',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    bookId,
    globalIndex,
    pageIndex,
    indexInPage,
    paragraph,
    lang,
    body,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sentences';
  @override
  VerificationContext validateIntegrity(
    Insertable<SentenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('global_index')) {
      context.handle(
        _globalIndexMeta,
        globalIndex.isAcceptableOrUnknown(
          data['global_index']!,
          _globalIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_globalIndexMeta);
    }
    if (data.containsKey('page_index')) {
      context.handle(
        _pageIndexMeta,
        pageIndex.isAcceptableOrUnknown(data['page_index']!, _pageIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIndexMeta);
    }
    if (data.containsKey('index_in_page')) {
      context.handle(
        _indexInPageMeta,
        indexInPage.isAcceptableOrUnknown(
          data['index_in_page']!,
          _indexInPageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_indexInPageMeta);
    }
    if (data.containsKey('paragraph')) {
      context.handle(
        _paragraphMeta,
        paragraph.isAcceptableOrUnknown(data['paragraph']!, _paragraphMeta),
      );
    } else if (isInserting) {
      context.missing(_paragraphMeta);
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    } else if (isInserting) {
      context.missing(_langMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, globalIndex};
  @override
  SentenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SentenceRow(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      globalIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}global_index'],
      )!,
      pageIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_index'],
      )!,
      indexInPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}index_in_page'],
      )!,
      paragraph: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paragraph'],
      )!,
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lang'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
    );
  }

  @override
  $SentencesTable createAlias(String alias) {
    return $SentencesTable(attachedDatabase, alias);
  }
}

class SentenceRow extends DataClass implements Insertable<SentenceRow> {
  final int bookId;
  final int globalIndex;
  final int pageIndex;
  final int indexInPage;
  final int paragraph;

  /// `Lang.index`.
  final int lang;
  final String body;
  const SentenceRow({
    required this.bookId,
    required this.globalIndex,
    required this.pageIndex,
    required this.indexInPage,
    required this.paragraph,
    required this.lang,
    required this.body,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<int>(bookId);
    map['global_index'] = Variable<int>(globalIndex);
    map['page_index'] = Variable<int>(pageIndex);
    map['index_in_page'] = Variable<int>(indexInPage);
    map['paragraph'] = Variable<int>(paragraph);
    map['lang'] = Variable<int>(lang);
    map['body'] = Variable<String>(body);
    return map;
  }

  SentencesCompanion toCompanion(bool nullToAbsent) {
    return SentencesCompanion(
      bookId: Value(bookId),
      globalIndex: Value(globalIndex),
      pageIndex: Value(pageIndex),
      indexInPage: Value(indexInPage),
      paragraph: Value(paragraph),
      lang: Value(lang),
      body: Value(body),
    );
  }

  factory SentenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SentenceRow(
      bookId: serializer.fromJson<int>(json['bookId']),
      globalIndex: serializer.fromJson<int>(json['globalIndex']),
      pageIndex: serializer.fromJson<int>(json['pageIndex']),
      indexInPage: serializer.fromJson<int>(json['indexInPage']),
      paragraph: serializer.fromJson<int>(json['paragraph']),
      lang: serializer.fromJson<int>(json['lang']),
      body: serializer.fromJson<String>(json['body']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<int>(bookId),
      'globalIndex': serializer.toJson<int>(globalIndex),
      'pageIndex': serializer.toJson<int>(pageIndex),
      'indexInPage': serializer.toJson<int>(indexInPage),
      'paragraph': serializer.toJson<int>(paragraph),
      'lang': serializer.toJson<int>(lang),
      'body': serializer.toJson<String>(body),
    };
  }

  SentenceRow copyWith({
    int? bookId,
    int? globalIndex,
    int? pageIndex,
    int? indexInPage,
    int? paragraph,
    int? lang,
    String? body,
  }) => SentenceRow(
    bookId: bookId ?? this.bookId,
    globalIndex: globalIndex ?? this.globalIndex,
    pageIndex: pageIndex ?? this.pageIndex,
    indexInPage: indexInPage ?? this.indexInPage,
    paragraph: paragraph ?? this.paragraph,
    lang: lang ?? this.lang,
    body: body ?? this.body,
  );
  SentenceRow copyWithCompanion(SentencesCompanion data) {
    return SentenceRow(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      globalIndex: data.globalIndex.present
          ? data.globalIndex.value
          : this.globalIndex,
      pageIndex: data.pageIndex.present ? data.pageIndex.value : this.pageIndex,
      indexInPage: data.indexInPage.present
          ? data.indexInPage.value
          : this.indexInPage,
      paragraph: data.paragraph.present ? data.paragraph.value : this.paragraph,
      lang: data.lang.present ? data.lang.value : this.lang,
      body: data.body.present ? data.body.value : this.body,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SentenceRow(')
          ..write('bookId: $bookId, ')
          ..write('globalIndex: $globalIndex, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('indexInPage: $indexInPage, ')
          ..write('paragraph: $paragraph, ')
          ..write('lang: $lang, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    bookId,
    globalIndex,
    pageIndex,
    indexInPage,
    paragraph,
    lang,
    body,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SentenceRow &&
          other.bookId == this.bookId &&
          other.globalIndex == this.globalIndex &&
          other.pageIndex == this.pageIndex &&
          other.indexInPage == this.indexInPage &&
          other.paragraph == this.paragraph &&
          other.lang == this.lang &&
          other.body == this.body);
}

class SentencesCompanion extends UpdateCompanion<SentenceRow> {
  final Value<int> bookId;
  final Value<int> globalIndex;
  final Value<int> pageIndex;
  final Value<int> indexInPage;
  final Value<int> paragraph;
  final Value<int> lang;
  final Value<String> body;
  final Value<int> rowid;
  const SentencesCompanion({
    this.bookId = const Value.absent(),
    this.globalIndex = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.indexInPage = const Value.absent(),
    this.paragraph = const Value.absent(),
    this.lang = const Value.absent(),
    this.body = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SentencesCompanion.insert({
    required int bookId,
    required int globalIndex,
    required int pageIndex,
    required int indexInPage,
    required int paragraph,
    required int lang,
    required String body,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       globalIndex = Value(globalIndex),
       pageIndex = Value(pageIndex),
       indexInPage = Value(indexInPage),
       paragraph = Value(paragraph),
       lang = Value(lang),
       body = Value(body);
  static Insertable<SentenceRow> custom({
    Expression<int>? bookId,
    Expression<int>? globalIndex,
    Expression<int>? pageIndex,
    Expression<int>? indexInPage,
    Expression<int>? paragraph,
    Expression<int>? lang,
    Expression<String>? body,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (globalIndex != null) 'global_index': globalIndex,
      if (pageIndex != null) 'page_index': pageIndex,
      if (indexInPage != null) 'index_in_page': indexInPage,
      if (paragraph != null) 'paragraph': paragraph,
      if (lang != null) 'lang': lang,
      if (body != null) 'body': body,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SentencesCompanion copyWith({
    Value<int>? bookId,
    Value<int>? globalIndex,
    Value<int>? pageIndex,
    Value<int>? indexInPage,
    Value<int>? paragraph,
    Value<int>? lang,
    Value<String>? body,
    Value<int>? rowid,
  }) {
    return SentencesCompanion(
      bookId: bookId ?? this.bookId,
      globalIndex: globalIndex ?? this.globalIndex,
      pageIndex: pageIndex ?? this.pageIndex,
      indexInPage: indexInPage ?? this.indexInPage,
      paragraph: paragraph ?? this.paragraph,
      lang: lang ?? this.lang,
      body: body ?? this.body,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (globalIndex.present) {
      map['global_index'] = Variable<int>(globalIndex.value);
    }
    if (pageIndex.present) {
      map['page_index'] = Variable<int>(pageIndex.value);
    }
    if (indexInPage.present) {
      map['index_in_page'] = Variable<int>(indexInPage.value);
    }
    if (paragraph.present) {
      map['paragraph'] = Variable<int>(paragraph.value);
    }
    if (lang.present) {
      map['lang'] = Variable<int>(lang.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SentencesCompanion(')
          ..write('bookId: $bookId, ')
          ..write('globalIndex: $globalIndex, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('indexInPage: $indexInPage, ')
          ..write('paragraph: $paragraph, ')
          ..write('lang: $lang, ')
          ..write('body: $body, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $PagesTable pages = $PagesTable(this);
  late final $SentencesTable sentences = $SentencesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final Index sentencesBookGlobal = Index(
    'sentences_book_global',
    'CREATE INDEX sentences_book_global ON sentences (book_id, global_index)',
  );
  late final Index sentencesBookPage = Index(
    'sentences_book_page',
    'CREATE INDEX sentences_book_page ON sentences (book_id, page_index)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    books,
    pages,
    sentences,
    settings,
    sentencesBookGlobal,
    sentencesBookPage,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pages', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sentences', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$BooksTableCreateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  required String title,
  required String fileHash,
  required String filePath,
  Value<String?> coverPath,
  required int pageCount,
  Value<int> emptyPageCount,
  Value<int> sentenceCount,
  Value<int> posPage,
  Value<int> posSentence,
  Value<int> posGlobal,
  required DateTime createdAt,
  Value<DateTime?> lastOpenedAt,
});
typedef $$BooksTableUpdateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> fileHash,
  Value<String> filePath,
  Value<String?> coverPath,
  Value<int> pageCount,
  Value<int> emptyPageCount,
  Value<int> sentenceCount,
  Value<int> posPage,
  Value<int> posSentence,
  Value<int> posGlobal,
  Value<DateTime> createdAt,
  Value<DateTime?> lastOpenedAt,
});

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, BookRow> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PagesTable, List<PageRow>> _pagesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.pages,
    aliasName: 'books__id__pages__book_id',
  );

  $$PagesTableProcessedTableManager get pagesRefs {
    final manager = $$PagesTableTableManager(
      $_db,
      $_db.pages,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SentencesTable, List<SentenceRow>>
  _sentencesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sentences,
    aliasName: 'books__id__sentences__book_id',
  );

  $$SentencesTableProcessedTableManager get sentencesRefs {
    final manager = $$SentencesTableTableManager(
      $_db,
      $_db.sentences,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sentencesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileHash => $composableBuilder(
    column: $table.fileHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get emptyPageCount => $composableBuilder(
    column: $table.emptyPageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sentenceCount => $composableBuilder(
    column: $table.sentenceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get posPage => $composableBuilder(
    column: $table.posPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get posSentence => $composableBuilder(
    column: $table.posSentence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get posGlobal => $composableBuilder(
    column: $table.posGlobal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> pagesRefs(
    Expression<bool> Function($$PagesTableFilterComposer f) f,
  ) {
    final $$PagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pages,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableFilterComposer(
            $db: $db,
            $table: $db.pages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sentencesRefs(
    Expression<bool> Function($$SentencesTableFilterComposer f) f,
  ) {
    final $$SentencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableFilterComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileHash => $composableBuilder(
    column: $table.fileHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get emptyPageCount => $composableBuilder(
    column: $table.emptyPageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sentenceCount => $composableBuilder(
    column: $table.sentenceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get posPage => $composableBuilder(
    column: $table.posPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get posSentence => $composableBuilder(
    column: $table.posSentence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get posGlobal => $composableBuilder(
    column: $table.posGlobal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get fileHash =>
      $composableBuilder(column: $table.fileHash, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<int> get emptyPageCount => $composableBuilder(
    column: $table.emptyPageCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sentenceCount => $composableBuilder(
    column: $table.sentenceCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get posPage =>
      $composableBuilder(column: $table.posPage, builder: (column) => column);

  GeneratedColumn<int> get posSentence => $composableBuilder(
    column: $table.posSentence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get posGlobal =>
      $composableBuilder(column: $table.posGlobal, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => column,
  );

  Expression<T> pagesRefs<T extends Object>(
    Expression<T> Function($$PagesTableAnnotationComposer a) f,
  ) {
    final $$PagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pages,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagesTableAnnotationComposer(
            $db: $db,
            $table: $db.pages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sentencesRefs<T extends Object>(
    Expression<T> Function($$SentencesTableAnnotationComposer a) f,
  ) {
    final $$SentencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableAnnotationComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          BookRow,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (BookRow, $$BooksTableReferences),
          BookRow,
          PrefetchHooks Function({bool pagesRefs, bool sentencesRefs})
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> fileHash = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<int> pageCount = const Value.absent(),
                Value<int> emptyPageCount = const Value.absent(),
                Value<int> sentenceCount = const Value.absent(),
                Value<int> posPage = const Value.absent(),
                Value<int> posSentence = const Value.absent(),
                Value<int> posGlobal = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastOpenedAt = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                title: title,
                fileHash: fileHash,
                filePath: filePath,
                coverPath: coverPath,
                pageCount: pageCount,
                emptyPageCount: emptyPageCount,
                sentenceCount: sentenceCount,
                posPage: posPage,
                posSentence: posSentence,
                posGlobal: posGlobal,
                createdAt: createdAt,
                lastOpenedAt: lastOpenedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String fileHash,
                required String filePath,
                Value<String?> coverPath = const Value.absent(),
                required int pageCount,
                Value<int> emptyPageCount = const Value.absent(),
                Value<int> sentenceCount = const Value.absent(),
                Value<int> posPage = const Value.absent(),
                Value<int> posSentence = const Value.absent(),
                Value<int> posGlobal = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> lastOpenedAt = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                title: title,
                fileHash: fileHash,
                filePath: filePath,
                coverPath: coverPath,
                pageCount: pageCount,
                emptyPageCount: emptyPageCount,
                sentenceCount: sentenceCount,
                posPage: posPage,
                posSentence: posSentence,
                posGlobal: posGlobal,
                createdAt: createdAt,
                lastOpenedAt: lastOpenedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BooksTable, BookRow>(table),
                  $$BooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pagesRefs = false, sentencesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (pagesRefs) db.pages,
                if (sentencesRefs) db.sentences,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (pagesRefs)
                    await $_getPrefetchedData<BookRow, $BooksTable, PageRow>(
                      currentTable: table,
                      referencedTable: $$BooksTableReferences._pagesRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$BooksTableReferences(db, table, p0).pagesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.bookId == item.id),
                      typedResults: items,
                    ),
                  if (sentencesRefs)
                    await $_getPrefetchedData<
                      BookRow,
                      $BooksTable,
                      SentenceRow
                    >(
                      currentTable: table,
                      referencedTable: $$BooksTableReferences
                          ._sentencesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BooksTableReferences(db, table, p0).sentencesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.bookId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      BookRow,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (BookRow, $$BooksTableReferences),
      BookRow,
      PrefetchHooks Function({bool pagesRefs, bool sentencesRefs})
    >;
typedef $$PagesTableCreateCompanionBuilder = PagesCompanion Function({
  required int bookId,
  required int pageIndex,
  required bool hasText,
  required int firstGlobal,
  required int sentenceCount,
  Value<int> rowid,
});
typedef $$PagesTableUpdateCompanionBuilder = PagesCompanion Function({
  Value<int> bookId,
  Value<int> pageIndex,
  Value<bool> hasText,
  Value<int> firstGlobal,
  Value<int> sentenceCount,
  Value<int> rowid,
});

final class $$PagesTableReferences
    extends BaseReferences<_$AppDatabase, $PagesTable, PageRow> {
  $$PagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('pages__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PagesTableFilterComposer extends Composer<_$AppDatabase, $PagesTable> {
  $$PagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasText => $composableBuilder(
    column: $table.hasText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstGlobal => $composableBuilder(
    column: $table.firstGlobal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sentenceCount => $composableBuilder(
    column: $table.sentenceCount,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagesTableOrderingComposer
    extends Composer<_$AppDatabase, $PagesTable> {
  $$PagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasText => $composableBuilder(
    column: $table.hasText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstGlobal => $composableBuilder(
    column: $table.firstGlobal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sentenceCount => $composableBuilder(
    column: $table.sentenceCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PagesTable> {
  $$PagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get pageIndex =>
      $composableBuilder(column: $table.pageIndex, builder: (column) => column);

  GeneratedColumn<bool> get hasText =>
      $composableBuilder(column: $table.hasText, builder: (column) => column);

  GeneratedColumn<int> get firstGlobal => $composableBuilder(
    column: $table.firstGlobal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sentenceCount => $composableBuilder(
    column: $table.sentenceCount,
    builder: (column) => column,
  );

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PagesTable,
          PageRow,
          $$PagesTableFilterComposer,
          $$PagesTableOrderingComposer,
          $$PagesTableAnnotationComposer,
          $$PagesTableCreateCompanionBuilder,
          $$PagesTableUpdateCompanionBuilder,
          (PageRow, $$PagesTableReferences),
          PageRow,
          PrefetchHooks Function({bool bookId})
        > {
  $$PagesTableTableManager(_$AppDatabase db, $PagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> bookId = const Value.absent(),
                Value<int> pageIndex = const Value.absent(),
                Value<bool> hasText = const Value.absent(),
                Value<int> firstGlobal = const Value.absent(),
                Value<int> sentenceCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PagesCompanion(
                bookId: bookId,
                pageIndex: pageIndex,
                hasText: hasText,
                firstGlobal: firstGlobal,
                sentenceCount: sentenceCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int bookId,
                required int pageIndex,
                required bool hasText,
                required int firstGlobal,
                required int sentenceCount,
                Value<int> rowid = const Value.absent(),
              }) => PagesCompanion.insert(
                bookId: bookId,
                pageIndex: pageIndex,
                hasText: hasText,
                firstGlobal: firstGlobal,
                sentenceCount: sentenceCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PagesTable, PageRow>(table),
                  $$PagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$PagesTableReferences._bookIdTable(
                          db,
                        ),
                        referencedColumn: $$PagesTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PagesTable,
      PageRow,
      $$PagesTableFilterComposer,
      $$PagesTableOrderingComposer,
      $$PagesTableAnnotationComposer,
      $$PagesTableCreateCompanionBuilder,
      $$PagesTableUpdateCompanionBuilder,
      (PageRow, $$PagesTableReferences),
      PageRow,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$SentencesTableCreateCompanionBuilder = SentencesCompanion Function({
  required int bookId,
  required int globalIndex,
  required int pageIndex,
  required int indexInPage,
  required int paragraph,
  required int lang,
  required String body,
  Value<int> rowid,
});
typedef $$SentencesTableUpdateCompanionBuilder = SentencesCompanion Function({
  Value<int> bookId,
  Value<int> globalIndex,
  Value<int> pageIndex,
  Value<int> indexInPage,
  Value<int> paragraph,
  Value<int> lang,
  Value<String> body,
  Value<int> rowid,
});

final class $$SentencesTableReferences
    extends BaseReferences<_$AppDatabase, $SentencesTable, SentenceRow> {
  $$SentencesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('sentences__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SentencesTableFilterComposer
    extends Composer<_$AppDatabase, $SentencesTable> {
  $$SentencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get globalIndex => $composableBuilder(
    column: $table.globalIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get indexInPage => $composableBuilder(
    column: $table.indexInPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paragraph => $composableBuilder(
    column: $table.paragraph,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SentencesTableOrderingComposer
    extends Composer<_$AppDatabase, $SentencesTable> {
  $$SentencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get globalIndex => $composableBuilder(
    column: $table.globalIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get indexInPage => $composableBuilder(
    column: $table.indexInPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paragraph => $composableBuilder(
    column: $table.paragraph,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SentencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SentencesTable> {
  $$SentencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get globalIndex => $composableBuilder(
    column: $table.globalIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pageIndex =>
      $composableBuilder(column: $table.pageIndex, builder: (column) => column);

  GeneratedColumn<int> get indexInPage => $composableBuilder(
    column: $table.indexInPage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paragraph =>
      $composableBuilder(column: $table.paragraph, builder: (column) => column);

  GeneratedColumn<int> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SentencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SentencesTable,
          SentenceRow,
          $$SentencesTableFilterComposer,
          $$SentencesTableOrderingComposer,
          $$SentencesTableAnnotationComposer,
          $$SentencesTableCreateCompanionBuilder,
          $$SentencesTableUpdateCompanionBuilder,
          (SentenceRow, $$SentencesTableReferences),
          SentenceRow,
          PrefetchHooks Function({bool bookId})
        > {
  $$SentencesTableTableManager(_$AppDatabase db, $SentencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SentencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SentencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SentencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> bookId = const Value.absent(),
                Value<int> globalIndex = const Value.absent(),
                Value<int> pageIndex = const Value.absent(),
                Value<int> indexInPage = const Value.absent(),
                Value<int> paragraph = const Value.absent(),
                Value<int> lang = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SentencesCompanion(
                bookId: bookId,
                globalIndex: globalIndex,
                pageIndex: pageIndex,
                indexInPage: indexInPage,
                paragraph: paragraph,
                lang: lang,
                body: body,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int bookId,
                required int globalIndex,
                required int pageIndex,
                required int indexInPage,
                required int paragraph,
                required int lang,
                required String body,
                Value<int> rowid = const Value.absent(),
              }) => SentencesCompanion.insert(
                bookId: bookId,
                globalIndex: globalIndex,
                pageIndex: pageIndex,
                indexInPage: indexInPage,
                paragraph: paragraph,
                lang: lang,
                body: body,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SentencesTable, SentenceRow>(table),
                  $$SentencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$SentencesTableReferences
                            ._bookIdTable(db),
                        referencedColumn: $$SentencesTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SentencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SentencesTable,
      SentenceRow,
      $$SentencesTableFilterComposer,
      $$SentencesTableOrderingComposer,
      $$SentencesTableAnnotationComposer,
      $$SentencesTableCreateCompanionBuilder,
      $$SentencesTableUpdateCompanionBuilder,
      (SentenceRow, $$SentencesTableReferences),
      SentenceRow,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$PagesTableTableManager get pages =>
      $$PagesTableTableManager(_db, _db.pages);
  $$SentencesTableTableManager get sentences =>
      $$SentencesTableTableManager(_db, _db.sentences);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
