import 'dart:async';

import 'package:audio_service/audio_service.dart';

import 'reader_player.dart';

/// Bridges [ReaderPlayer] to Android's media session: notification,
/// lock-screen and headset controls. "Skip" moves by one sentence.
class QariAudioHandler extends BaseAudioHandler {
  QariAudioHandler(this._player) {
    _sub = _player.states.listen(_publish);
  }

  final ReaderPlayer _player;
  late final StreamSubscription<ReaderState> _sub;
  int? _lastBookId;
  int? _lastPage;

  void _publish(ReaderState s) {
    final book = s.book;
    if (book == null) return;

    if (book.id != _lastBookId || s.pageIndex != _lastPage) {
      _lastBookId = book.id;
      _lastPage = s.pageIndex;
      mediaItem.add(
        MediaItem(
          id: 'book-${book.id}',
          title: book.title,
          album: 'Qari',
          artist: '${s.pageIndex + 1} / ${book.pageCount}',
          artUri: book.coverPath == null ? null : Uri.file(book.coverPath!),
        ),
      );
    }

    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (s.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.playPause,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: s.finished
            ? AudioProcessingState.completed
            : s.buffering
            ? AudioProcessingState.buffering
            : AudioProcessingState.ready,
        playing: s.playing,
        speed: s.speed,
        queueIndex: s.globalIndex,
      ),
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> skipToNext() => _player.next();

  @override
  Future<void> skipToPrevious() => _player.previous();

  @override
  Future<void> fastForward() => _player.next();

  @override
  Future<void> rewind() => _player.previous();

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> stop() async {
    await _player.pause();
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
    await super.stop();
  }

  Future<void> dispose() => _sub.cancel();
}
