import 'dart:async';

import 'package:audio_session/audio_session.dart';

import 'reader_player.dart';

/// Pauses for phone calls / other apps and when headphones are unplugged,
/// and resumes after a transient interruption if we were playing.
void bindAudioFocus(AudioSession session, ReaderPlayer player) {
  var resumeAfter = false;
  session.interruptionEventStream.listen((e) {
    if (e.begin) {
      switch (e.type) {
        case AudioInterruptionType.duck:
          unawaited(player.audioPlayer.setVolume(0.3));
        case AudioInterruptionType.pause:
        case AudioInterruptionType.unknown:
          resumeAfter = player.state.playing;
          unawaited(player.pause());
      }
    } else {
      switch (e.type) {
        case AudioInterruptionType.duck:
          unawaited(player.audioPlayer.setVolume(1.0));
        case AudioInterruptionType.pause:
          if (resumeAfter) unawaited(player.play());
          resumeAfter = false;
        case AudioInterruptionType.unknown:
          resumeAfter = false;
      }
    }
  });
  session.becomingNoisyEventStream.listen((_) => unawaited(player.pause()));
}
