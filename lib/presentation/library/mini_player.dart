import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../player/player_screen.dart';

/// "Continue listening" bar shown in the library while a book is loaded.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(readerStateProvider).value;
    final book = state?.book;
    if (state == null || book == null) return const SizedBox.shrink();

    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final player = ref.read(readerPlayerProvider);
    return Material(
      color: t.colorScheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PlayerScreen(bookId: book.id),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 36,
                    height: 50,
                    child: book.coverPath == null
                        ? ColoredBox(color: t.colorScheme.primaryContainer)
                        : Image.file(File(book.coverPath!), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.titleSmall,
                      ),
                      Text(
                        state.current?.text ?? l.continueListening,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.bodySmall?.copyWith(
                          color: t.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: state.playing ? l.pause : l.play,
                  icon: Icon(
                    state.playing
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                  ),
                  iconSize: 40,
                  color: t.colorScheme.primary,
                  onPressed: () => unawaited(player.toggle()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
