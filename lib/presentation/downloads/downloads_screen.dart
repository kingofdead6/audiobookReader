import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/models/model_catalog.dart';
import '../../data/models/model_manager.dart';
import '../../data/system_channel.dart';
import '../../domain/entities/lang.dart';
import '../../l10n/gen/app_localizations.dart';
import '../widgets/error_text.dart';

final _freeSpaceProvider = FutureProvider.autoDispose<int?>((ref) {
  ref.watch(modelStatesProvider); // refresh after installs/deletes
  return const SystemChannel().freeBytes(ref.watch(appPathsProvider).models);
});

String _mb(int bytes) => (bytes / (1024 * 1024)).toStringAsFixed(0);

/// Lists downloadable voice models with progress, retry and delete.
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final states = ref.watch(modelStatesProvider);
    final free = ref.watch(_freeSpaceProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(l.voiceModels)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              l.voiceModelsIntro,
              style: t.textTheme.bodyMedium?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (free != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(l.freeSpace(_mb(free)), style: t.textTheme.bodySmall),
            ),
          for (final m in voiceModels)
            _ModelTile(
              model: m,
              progress:
                  states[m.id] ?? const ModelProgress(ModelStatus.checking),
            ),
        ],
      ),
    );
  }
}

class _ModelTile extends ConsumerWidget {
  const _ModelTile({required this.model, required this.progress});
  final VoiceModel model;
  final ModelProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final ctrl = ref.read(modelStatesProvider.notifier);

    final Widget status;
    final List<Widget> actions;
    switch (progress.status) {
      case ModelStatus.checking:
        status = const LinearProgressIndicator();
        actions = const [];
      case ModelStatus.installed:
        status = Row(
          children: [
            Icon(Icons.check_circle, size: 18, color: t.colorScheme.primary),
            const SizedBox(width: 6),
            Text(l.installed),
          ],
        );
        actions = [
          TextButton.icon(
            onPressed: () => _confirmDelete(context, ref),
            icon: const Icon(Icons.delete_outline),
            label: Text(l.deleteBook),
          ),
        ];
      case ModelStatus.downloading:
        status = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: progress.fraction),
            const SizedBox(height: 4),
            Text(
              l.downloadedOf(_mb(progress.received), _mb(model.archiveBytes)),
            ),
          ],
        );
        actions = [
          TextButton(
            onPressed: () => ctrl.cancel(model),
            child: Text(l.cancel),
          ),
        ];
      case ModelStatus.verifying:
      case ModelStatus.extracting:
        status = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LinearProgressIndicator(),
            const SizedBox(height: 4),
            Text(
              progress.status == ModelStatus.verifying
                  ? l.verifying
                  : l.extracting,
            ),
          ],
        );
        actions = const [];
      case ModelStatus.notInstalled:
        final partial = progress.received > 0;
        status = Text(
          partial
              ? l.downloadedOf(_mb(progress.received), _mb(model.archiveBytes))
              : l.notDownloaded,
        );
        actions = [
          FilledButton.icon(
            onPressed: () => unawaited(ctrl.install(model)),
            icon: const Icon(Icons.download),
            label: Text(partial ? l.resume : l.download),
          ),
        ];
      case ModelStatus.failed:
        status = Text(
          errorMessage(l, progress.error ?? const Object()),
          style: TextStyle(color: t.colorScheme.error),
        );
        actions = [
          FilledButton.icon(
            onPressed: () => unawaited(ctrl.install(model)),
            icon: const Icon(Icons.refresh),
            label: Text(l.retry),
          ),
        ];
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text(
                    model.lang == Lang.ar ? 'ع' : 'En',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(model.title, style: t.textTheme.titleMedium),
                ),
                Text(
                  l.sizeMb(_mb(model.archiveBytes)),
                  style: t.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            status,
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(alignment: WrapAlignment.end, spacing: 8, children: actions),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Text(l.deleteModelConfirm(model.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l.deleteBook),
          ),
        ],
      ),
    );
    if (ok == true) await ref.read(modelStatesProvider.notifier).delete(model);
  }
}
