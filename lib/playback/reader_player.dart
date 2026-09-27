import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;

import '../core/errors.dart';
import '../domain/entities/book.dart';
import '../domain/entities/sentence.dart';
import '../domain/repositories/book_repository.dart';
import 'tts_router.dart';

/// Snapshot of the player for the UI and the media notification.
class ReaderState {
  const ReaderState({
    this.book,
    this.current,
    this.total = 0,
    this.playing = false,
    this.buffering = false,
    this.finished = false,
    this.error,
    this.speed = 1.0,
    this.sleepAt,
    this.sleepAtPageEnd = false,
  });

  final Book? book;
  final Sentence? current;
  final int total;

  /// The user wants audio (may still be buffering).
  final bool playing;
  final bool buffering;
  final bool finished;
  final AppException? error;
  final double speed;
  final DateTime? sleepAt;
  final bool sleepAtPageEnd;

  int get globalIndex => current?.globalIndex ?? 0;
  int get pageIndex => current?.pageIndex ?? book?.position.pageIndex ?? 0;
}

/// Streams a book sentence by sentence: while sentence N plays, N+1 and N+2
/// are synthesized in the background (never the whole book). Audio is
/// played from short WAV files, so speed, pause/seek and background
/// playback work the same for every engine.
class ReaderPlayer {
  ReaderPlayer({
    required this.books,
    required this.router,
    required this.cacheDir,
    AudioPlayer? player,
  }) : _player = player ?? AudioPlayer();

  final BookRepository books;
  final TtsRouter router;
  final String cacheDir;
  final AudioPlayer _player;

  /// Sentences synthesized ahead of the one playing.
  static const lookahead = 2;

  final _states = StreamController<ReaderState>.broadcast();
  ReaderState _state = const ReaderState();
  ReaderState get state => _state;
  Stream<ReaderState> get states => _states.stream;

  Book? _book;
  int _total = 0;
  int _current = 0;
  final _sentences = <int, Sentence>{};

  // Playback loop control. Every seek bumps [_gen]; a loop only acts while
  // its generation is current.
  int _gen = 0;
  int _activeLoop = -1;
  bool _wantPlay = false;
  int? _loadedIndex;
  Completer<void>? _wait;

  // Synthesis cache for the window [current, current + lookahead].
  int _epoch = 0;
  String _fingerprint = '';
  bool _workerBusy = false;
  final _ready = <int, String>{};
  final _errors = <int, AppException>{};
  final _waiters = <int, List<Completer<String>>>{};

  // Sleep timer.
  Timer? _sleepTimer;
  DateTime? _sleepAt;
  bool _sleepAtPageEnd = false;
  AppException? _error;
  bool _finished = false;

  AudioPlayer get audioPlayer => _player;
  int get currentIndex => _current;
  Book? get book => _book;

  // ---------------------------------------------------------------- open

  Future<void> open(int bookId) async {
    if (_book?.id == bookId) {
      _emit();
      return;
    }
    await stop();
    final book = await books.getBook(bookId);
    if (book == null) return;
    _invalidateAudio();
    _sentences.clear();
    _book = book;
    _total = book.sentenceCount;
    _current = _total == 0 ? 0 : book.position.globalIndex.clamp(0, _total - 1);
    _finished = false;
    _error = null;
    await books.markOpened(bookId);
    await _sentence(_current);
    _emit();
    _kickWorker(); // first sentence is ready when the user presses play
  }

  // ------------------------------------------------------------ controls

  Future<void> play() async {
    if (_book == null || _total == 0) return;
    if (_finished) {
      _finished = false;
      await seekTo(0);
    }
    _error = null;
    _wantPlay = true;
    _emit();
    if (_activeLoop == _gen) {
      if (_loadedIndex == _current) unawaited(_player.play());
    } else {
      unawaited(_runLoop());
    }
  }

  Future<void> pause() async {
    _wantPlay = false;
    await _player.pause();
    _emit();
  }

  Future<void> toggle() => _wantPlay ? pause() : play();

  Future<void> next() => seekTo(_current + 1);
  Future<void> previous() => seekTo(_current - 1);

  Future<void> seekTo(int globalIndex) async {
    if (_book == null || _total == 0) return;
    _gen++;
    if (_wait != null && !_wait!.isCompleted) _wait!.complete();
    await _player.stop();
    _loadedIndex = null;
    _finished = false;
    _current = globalIndex.clamp(0, _total - 1);
    await _sentence(_current);
    await _savePosition();
    _prune();
    _emit();
    if (_wantPlay) {
      unawaited(_runLoop());
    } else {
      _kickWorker();
    }
  }

  /// Jumps to the first sentence on [pageIndex] or the next page with text.
  Future<void> jumpToPage(int pageIndex) async {
    final book = _book;
    if (book == null) return;
    final infos = await books.pageInfos(book.id);
    final target = infos
        .where((i) => i.pageIndex >= pageIndex && i.sentenceCount > 0)
        .firstOrNull;
    await seekTo(target?.firstGlobal ?? _total - 1);
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed.clamp(0.5, 2.0));
    _emit();
  }

  /// [duration] null cancels; [atPageEnd] pauses when the page changes.
  void setSleepTimer({Duration? duration, bool atPageEnd = false}) {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepAt = null;
    _sleepAtPageEnd = atPageEnd;
    if (duration != null) {
      _sleepAt = DateTime.now().add(duration);
      _sleepTimer = Timer(duration, () {
        _sleepAt = null;
        unawaited(pause());
      });
    }
    _emit();
  }

  Future<void> stop() async {
    _wantPlay = false;
    _gen++;
    if (_wait != null && !_wait!.isCompleted) _wait!.complete();
    await _player.stop();
    _loadedIndex = null;
    _emit();
  }

  /// Settings changed (engine/voice): drop prepared audio.
  void onVoiceSettingsChanged() {
    if (router.fingerprint() == _fingerprint) return;
    _invalidateAudio();
    if (_book != null) {
      // Re-render the current sentence with the new voice on next play.
      if (_loadedIndex != null && !_wantPlay) _loadedIndex = null;
      _kickWorker();
    }
  }

  Future<void> dispose() async {
    await stop();
    _sleepTimer?.cancel();
    _invalidateAudio();
    await _player.dispose();
    await _states.close();
  }

  // ---------------------------------------------------------------- loop

  Future<void> _runLoop() async {
    final gen = _gen;
    _activeLoop = gen;
    try {
      while (_wantPlay && gen == _gen) {
        if (_current >= _total) {
          _wantPlay = false;
          _finished = true;
          _emit();
          return;
        }

        if (_loadedIndex != _current) {
          _emit(buffering: true);
          final String path;
          try {
            path = await _fileFor(_current);
          } on AppException catch (e) {
            if (gen != _gen) return;
            if (e.kind == AppErrorKind.languageUnavailable) {
              _wantPlay = false;
              _error = e;
              _emit();
              return;
            }
            // Unspeakable chunk: skip it rather than stall the book.
            await _advance();
            continue;
          }
          if (gen != _gen || !_wantPlay) return;
          await _player.setFilePath(path);
          _loadedIndex = _current;
          _emit();
        }

        final wait = _wait = Completer<void>();
        final sub = _player.processingStateStream.listen((s) {
          if (s == ProcessingState.completed && !wait.isCompleted) {
            wait.complete();
          }
        });
        unawaited(_player.play());
        await wait.future;
        await sub.cancel();
        if (gen != _gen) return;

        final pageBefore = _sentences[_current]?.pageIndex;
        await _advance();
        final pageAfter = _sentences[_current]?.pageIndex;
        if (_sleepAtPageEnd && pageBefore != pageAfter) {
          _sleepAtPageEnd = false;
          _wantPlay = false;
          _emit();
          return;
        }
      }
    } catch (e) {
      if (gen == _gen) {
        _wantPlay = false;
        _error = e is AppException
            ? e
            : AppException(AppErrorKind.unknown, '$e');
        _emit();
      }
    } finally {
      if (_activeLoop == gen) _activeLoop = -1;
    }
  }

  Future<void> _advance() async {
    _loadedIndex = null;
    _current++;
    if (_current >= _total) {
      _current = _total - 1;
      _wantPlay = false;
      _finished = true;
      await _player.stop();
      _emit();
      return;
    }
    await _sentence(_current);
    await _savePosition();
    _prune();
    _emit();
  }

  // ------------------------------------------------------------ synthesis

  Future<String> _fileFor(int i) {
    final ready = _ready[i];
    if (ready != null) return Future.value(ready);
    final err = _errors[i];
    if (err != null) return Future.error(err);
    final c = Completer<String>();
    (_waiters[i] ??= []).add(c);
    _kickWorker();
    return c.future;
  }

  void _kickWorker() {
    if (_workerBusy || _book == null) return;
    _workerBusy = true;
    unawaited(_work().whenComplete(() => _workerBusy = false));
  }

  /// Synthesizes the first missing sentence of the window, repeatedly.
  Future<void> _work() async {
    while (true) {
      final book = _book;
      if (book == null) return;
      final end = math.min(_current + lookahead, _total - 1);
      int? target;
      for (var i = _current; i <= end; i++) {
        if (!_ready.containsKey(i) && !_errors.containsKey(i)) {
          target = i;
          break;
        }
      }
      if (target == null) return;

      final epoch = _epoch;
      final s = await _sentence(target);
      final out = p.join(cacheDir, 'b${book.id}_s${target}_e$epoch.wav');
      try {
        if (s == null) {
          throw const AppException(AppErrorKind.unknown, 'missing');
        }
        await router.synthesize(s.text, s.lang, out);
        if (epoch != _epoch) {
          _deleteQuietly(out);
          continue;
        }
        _ready[target] = out;
        for (final w
            in _waiters.remove(target) ?? const <Completer<String>>[]) {
          w.complete(out);
        }
      } catch (e) {
        if (epoch != _epoch) continue;
        final err = e is AppException
            ? e
            : AppException(AppErrorKind.engineFailed, '$e');
        _errors[target] = err;
        for (final w
            in _waiters.remove(target) ?? const <Completer<String>>[]) {
          w.completeError(err);
        }
      }
    }
  }

  void _invalidateAudio() {
    _epoch++;
    _fingerprint = router.fingerprint();
    for (final f in _ready.values) {
      if (_loadedIndex != null && f == _ready[_loadedIndex]) continue;
      _deleteQuietly(f);
    }
    final keep = _loadedIndex == null ? null : _ready[_loadedIndex];
    _ready.clear();
    if (keep != null && _loadedIndex != null) _ready[_loadedIndex!] = keep;
    _errors.clear();
    for (final ws in _waiters.values) {
      for (final w in ws) {
        w.completeError(const AppException(AppErrorKind.unknown, 'cancelled'));
      }
    }
    _waiters.clear();
  }

  /// Deletes audio that is behind the reader or far ahead after a seek.
  void _prune() {
    final keepFrom = _current - 1;
    final keepTo = _current + lookahead;
    for (final i in _ready.keys.toList()) {
      if (i < keepFrom || i > keepTo) _deleteQuietly(_ready.remove(i)!);
    }
    _errors.removeWhere((i, _) => i < _current);
  }

  static void _deleteQuietly(String path) {
    File(path).delete().ignore();
  }

  // -------------------------------------------------------------- helpers

  Future<Sentence?> _sentence(int i) async {
    final book = _book;
    if (book == null || i < 0 || i >= _total) return null;
    final hit = _sentences[i];
    if (hit != null) return hit;
    final from = math.max(0, i - 5);
    final list = await books.sentences(book.id, from, 60);
    if (_sentences.length > 600) _sentences.clear();
    for (final s in list) {
      _sentences[s.globalIndex] = s;
    }
    return _sentences[i];
  }

  Future<void> _savePosition() async {
    final book = _book;
    if (book == null) return;
    await books.savePosition(book.id, _current);
  }

  void _emit({bool buffering = false}) {
    if (_states.isClosed) return;
    _state = ReaderState(
      book: _book,
      current: _sentences[_current],
      total: _total,
      playing: _wantPlay,
      buffering: buffering,
      finished: _finished,
      error: _error,
      speed: _player.speed,
      sleepAt: _sleepAt,
      sleepAtPageEnd: _sleepAtPageEnd,
    );
    _states.add(_state);
  }
}
