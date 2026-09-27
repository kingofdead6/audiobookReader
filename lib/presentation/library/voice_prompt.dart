import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/models/model_manager.dart';
import '../../l10n/gen/app_localizations.dart';
import '../downloads/downloads_screen.dart';

/// First-launch card offering the natural voice downloads. Hidden once the
/// user dismisses it or any model is installed or downloading.
class VoicePrompt extends ConsumerWidget {
  const VoicePrompt({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final states = ref.watch(modelStatesProvider).values;
    final show =
        !settings.voicePromptDismissed &&
        states.every(
          (s) =>
              s.status == ModelStatus.notInstalled ||
              s.status == ModelStatus.failed,
        );
    if (!show) return const SizedBox.shrink();

    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    return Card(
      color: t.colorScheme.primaryContainer,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.record_voice_over,
                  color: t.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  l.getVoicesTitle,
                  style: t.textTheme.titleMedium?.copyWith(
                    color: t.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l.getVoicesBody,
              style: TextStyle(color: t.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => ref
                      .read(settingsProvider.notifier)
                      .update((s) => s.copyWith(voicePromptDismissed: true)),
                  child: Text(l.later),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DownloadsScreen(),
                    ),
                  ),
                  child: Text(l.download),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
