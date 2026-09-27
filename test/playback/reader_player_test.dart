import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qari/core/errors.dart';
import 'package:qari/domain/entities/app_settings.dart';
import 'package:qari/domain/entities/book.dart';
import 'package:qari/domain/entities/lang.dart';
import 'package:qari/domain/entities/sentence.dart';
import 'package:qari/domain/repositories/book_repository.dart';
import 'package:qari/domain/tts/tts_engine.dart';
import 'package:qari/playback/reader_player.dart';
import 'package:qari/playback/tts_router.dart';

/// Plays instantly; a test completes the current "file" with [finish].
class FakeAudioPlayer implements AudioPlayer {
  final _states = StreamController<ProcessingState>.broadcast();
  final loaded = <String>[];
  bool isPlaying = false;
  double _speed = 1;

  void finish() => _states.add(ProcessingState.completed);

  @override
  Stream<ProcessingState> get processingStateStream => _states.stream;
  @override
  Future<Duration?> setFilePath(
    String filePath, {
    Duration? initialPosition,
    bool preload = true,
    dynamic tag,
  }) async {
    loaded.add(filePath);
    _states.add(ProcessingState.ready);
    return const Duration(seconds: 1);
  }

  @override
  Future<void> play() async => isPlaying = true;
  @override
  Future<void> pause() async => isPlaying = false;
  @override
  Future<void> stop() async => isPlaying = false;
  @override
  Future<void> setSpeed(double speed) async => _speed = speed;
  @override
  double get speed => _speed;
  @override
  Future<void> dispose() async => _states.close();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeEngine implements TtsEngine {
  final synthesized = <String>[];
  final failing = <String>{};
  AppException? failWith;

  @override
  TtsEngineId get id => TtsEngineId.system;
  @override
  Future<void> init() async {}
  @override
  Future<bool> supports(Lang lang) async => true;
  @override
  Future<List<TtsVoice>> voices(Lang lang) async => const [];
  @override
  Future<void> synthesize(
    String text,
    Lang lang, {
    required String outPath,
    String? voiceId,
  }) async {
    await Future<void>.delayed(Duration.zero);
    if (failWith != null) throw failWith!;
    if (failing.contains(text)) {
      throw const AppException(AppErrorKind.engineFailed, 'bad');
    }
    synthesized.add(text);
  }

  @override
  Future<void> dispose() async {}
}

/// 3 pages x 3 sentences; page 1 (the middle one) is empty.
class MemoryBooks implements BookRepository {
  MemoryBooks({this.start = 0});
  final int start;
  int saved = -1;

  late final items = [
    for (var g = 0; g < 6; g++)
      Sentence(
        pageIndex: g < 3 ? 0 : 2,
        indexInPage: g % 3,
        globalIndex: g,
        paragraph: 0,
        text: 's$g',
        lang: g.isEven ? Lang.en : Lang.ar,
      ),
  ];

  @override
  Future<Book?> getBook(int id) async => Book(
    id: id,
    title: 'Test',
    filePath: '/x.pdf',
    coverPath: null,
    pageCount: 3,
    emptyPageCount: 1,
    sentenceCount: items.length,
    position: ReadingPosition(
      pageIndex: 0,
      sentenceInPage: 0,
      globalIndex: start,
    ),
    createdAt: DateTime(2026),
  );

  @override
  Future<List<Sentence>> sentences(
    int bookId,
    int fromGlobal,
    int count,
  ) async => items.skip(fromGlobal).take(count).toList();

  @override
  Future<void> savePosition(int bookId, int globalIndex) async =>
      saved = globalIndex;

  @override
  Future<void> markOpened(int bookId) async {}

  @override
  Future<List<PageInfo>> pageInfos(int bookId) async => const [
    PageInfo(pageIndex: 0, hasText: true, firstGlobal: 0, sentenceCount: 3),
    PageInfo(pageIndex: 1, hasText: false, firstGlobal: 3, sentenceCount: 0),
    PageInfo(pageIndex: 2, hasText: true, firstGlobal: 3, sentenceCount: 3),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> settle() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late FakeAudioPlayer audio;
  late FakeEngine engine;
  late MemoryBooks books;
  late ReaderPlayer player;

  Future<void> setUpPlayer({
    int start = 0,
    Set<String> failing = const {},
  }) async {
    audio = FakeAudioPlayer();
    engine = FakeEngine()..failing.addAll(failing);
    books = MemoryBooks(start: start);
    player = ReaderPlayer(
      books: books,
      router: TtsRouter(
        engines: {TtsEngineId.system: engine},
        settings: () => const AppSettings(),
      ),
      cacheDir: '/tmp',
      player: audio,
    );
    await player.open(1);
    await settle();
  }

  test('open restores position and prefetches only N, N+1, N+2', () async {
    await setUpPlayer(start: 2);
    expect(player.state.current?.globalIndex, 2);
    expect(engine.synthesized, ['s2', 's3', 's4']);
  });

  test('plays sentences in order, saving position, until the end', () async {
    await setUpPlayer();
    await player.play();
    await settle();
    for (var i = 0; i < 6; i++) {
      expect(player.state.current?.globalIndex, i);
      expect(audio.isPlaying, isTrue);
      audio.finish();
      await settle();
    }
    expect(player.state.finished, isTrue);
    expect(player.state.playing, isFalse);
    expect(books.saved, 5);
    expect(audio.loaded, hasLength(6));
    // Never more than 2 sentences ahead of the one playing.
    expect(engine.synthesized, ['s0', 's1', 's2', 's3', 's4', 's5']);
  });

  test('seek while playing continues from the new sentence', () async {
    await setUpPlayer();
    await player.play();
    await settle();
    await player.seekTo(4);
    await settle();
    expect(player.state.current?.globalIndex, 4);
    expect(audio.loaded.last, contains('_s4_'));
    audio.finish();
    await settle();
    expect(player.state.current?.globalIndex, 5);
    expect(books.saved, 5);
  });

  test('pause and resume keep the loaded sentence', () async {
    await setUpPlayer();
    await player.play();
    await settle();
    await player.pause();
    expect(audio.isPlaying, isFalse);
    expect(player.state.playing, isFalse);
    await player.play();
    await settle();
    expect(audio.isPlaying, isTrue);
    expect(audio.loaded, hasLength(1)); // not re-loaded
    audio.finish();
    await settle();
    expect(player.state.current?.globalIndex, 1);
  });

  test('jumpToPage skips empty pages', () async {
    await setUpPlayer();
    await player.jumpToPage(1);
    expect(player.state.current?.globalIndex, 3);
    expect(player.state.pageIndex, 2);
  });

  test('a failing sentence is skipped, not fatal', () async {
    await setUpPlayer(failing: {'s1'});
    await player.play();
    await settle();
    audio.finish(); // s0 done
    await settle();
    expect(player.state.current?.globalIndex, 2);
    expect(player.state.playing, isTrue);
  });

  test('missing language voice stops playback with an error', () async {
    audio = FakeAudioPlayer();
    engine = FakeEngine()
      ..failWith = const AppException(AppErrorKind.languageUnavailable, 'ar');
    books = MemoryBooks();
    player = ReaderPlayer(
      books: books,
      router: TtsRouter(
        engines: {TtsEngineId.system: engine},
        settings: () => const AppSettings(),
      ),
      cacheDir: '/tmp',
      player: audio,
    );
    await player.open(1);
    await player.play();
    await settle();
    expect(player.state.playing, isFalse);
    expect(player.state.error?.kind, AppErrorKind.languageUnavailable);
  });

  test('sleep at end of page pauses when the page changes', () async {
    await setUpPlayer(start: 2);
    player.setSleepTimer(atPageEnd: true);
    await player.play();
    await settle();
    audio.finish(); // s2 (last on page 0) done -> page 2
    await settle();
    expect(player.state.current?.globalIndex, 3);
    expect(player.state.playing, isFalse);
  });

  test('speed is applied to the audio player', () async {
    await setUpPlayer();
    await player.setSpeed(1.5);
    expect(audio.speed, 1.5);
    await player.setSpeed(9);
    expect(audio.speed, 2.0);
  });
}
