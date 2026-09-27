import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../app/providers.dart';
import '../../domain/entities/book.dart';
import '../../domain/usecases/import_book.dart';
import '../../l10n/gen/app_localizations.dart';
import '../player/player_screen.dart';
import '../preview/text_preview_screen.dart';
import '../settings/settings_screen.dart';
import '../widgets/error_text.dart';
import 'book_card.dart';
import 'mini_player.dart';
import 'voice_prompt.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  static void openBook(BuildContext context, Book book) => Navigator.of(context)
      .push(
        MaterialPageRoute<void>(builder: (_) => PlayerScreen(bookId: book.id)),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final books = ref.watch(booksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.appTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: l.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _import(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l.importPdf),
      ),
      body: Column(
        children: [
          const VoicePrompt(),
          Expanded(
            child: books.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(errorMessage(l, e))),
              data: (list) => list.isEmpty
                  ? _EmptyLibrary(onImport: () => _import(context, ref))
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.52,
                          ),
                      itemCount: list.length,
                      itemBuilder: (context, i) => BookCard(
                        book: list[i],
                        onTap: () => openBook(context, list[i]),
                        onPreview: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                TextPreviewScreen(bookId: list[i].id),
                          ),
                        ),
                        onDelete: () => _delete(context, ref, list[i]),
                      ),
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final PlatformFile? picked;
    try {
      picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(l, e))));
      return;
    }
    if (picked == null || !context.mounted) return;

    final progress = ValueNotifier(const ImportProgress(ImportStage.copying));
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            PopScope(canPop: false, child: _ImportDialog(progress: progress)),
      ),
    );

    String? tempCopy;
    try {
      var path = picked.path;
      if (path == null) {
        // Content URI (e.g. Google Drive): stream it into the cache first.
        final paths = ref.read(appPathsProvider);
        tempCopy = p.join(
          paths.cache,
          'import_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        final sink = File(tempCopy).openWrite();
        await sink.addStream(picked.readAsByteStream());
        await sink.close();
        path = tempCopy;
      }
      await ref.read(importBookProvider)(
        path,
        displayName: picked.name,
        onProgress: (pr) => progress.value = pr,
      );
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(l.importDone(p.basenameWithoutExtension(picked.name))),
        ),
      );
    } catch (e) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (c) => AlertDialog(
            icon: const Icon(Icons.error_outline),
            title: Text(l.importFailed),
            content: Text(errorMessage(l, e)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: Text(l.ok)),
            ],
          ),
        );
      }
    } finally {
      progress.dispose();
      if (tempCopy != null) {
        try {
          await File(tempCopy).delete();
        } catch (_) {}
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Book book) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Text(l.deleteBookConfirm(book.title)),
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
    if (ok != true) return;
    final player = ref.read(readerPlayerProvider);
    if (player.book?.id == book.id) await player.close();
    await ref.read(bookRepositoryProvider).deleteBook(book.id);
    for (final f in [book.filePath, book.coverPath]) {
      if (f == null) continue;
      try {
        await File(f).delete();
      } catch (_) {}
    }
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.onImport});
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 72,
              color: t.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(l.emptyLibraryTitle, style: t.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              l.emptyLibraryHint,
              textAlign: TextAlign.center,
              style: t.textTheme.bodyMedium?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.file_open_outlined),
              label: Text(l.importPdf),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportDialog extends StatelessWidget {
  const _ImportDialog({required this.progress});
  final ValueNotifier<ImportProgress> progress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.importing),
      content: ValueListenableBuilder(
        valueListenable: progress,
        builder: (context, pr, _) {
          final text = switch (pr.stage) {
            ImportStage.copying => l.importStageCopying,
            ImportStage.extracting => l.importStageExtracting(
              pr.done,
              pr.total,
            ),
            ImportStage.processing => l.importStageProcessing,
            ImportStage.saving => l.importStageSaving,
          };
          final value = pr.stage == ImportStage.extracting && pr.total > 0
              ? pr.done / pr.total
              : null;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(value: value),
              const SizedBox(height: 12),
              Text(text),
            ],
          );
        },
      ),
    );
  }
}
