import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../playback/reader_player.dart';
import 'speed_sleep_controls.dart';

/// Bottom transport bar: progress, previous / play-pause / next.
class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key, required this.state, required this.player});

  final ReaderState state;
  final ReaderPlayer player;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final total = state.total;
    final progress = total <= 1 ? 0.0 : state.globalIndex / (total - 1);

    return Material(
      color: t.colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    '${(progress * 100).round()}%',
                    style: t.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpeedButton(state: state),
                  IconButton(
                    tooltip: l.previousSentence,
                    iconSize: 32,
                    // Transport icons keep their meaning in RTL.
                    icon: const Icon(Icons.skip_previous_rounded),
                    onPressed: () => unawaited(player.previous()),
                  ),
                  const SizedBox(width: 12),
                  _PlayButton(state: state, player: player),
                  const SizedBox(width: 12),
                  IconButton(
                    tooltip: l.nextSentence,
                    iconSize: 32,
                    icon: const Icon(Icons.skip_next_rounded),
                    onPressed: () => unawaited(player.next()),
                  ),
                  SleepButton(state: state),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.state, required this.player});
  final ReaderState state;
  final ReaderPlayer player;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (state.buffering)
            SizedBox(
              width: 72,
              height: 72,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: t.colorScheme.primary,
              ),
            ),
          IconButton.filled(
            tooltip: state.buffering
                ? l.preparingVoice
                : (state.playing ? l.pause : l.play),
            iconSize: 40,
            style: IconButton.styleFrom(fixedSize: const Size(64, 64)),
            icon: Icon(
              state.playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
            ),
            onPressed: () => unawaited(player.toggle()),
          ),
        ],
      ),
    );
  }
}
