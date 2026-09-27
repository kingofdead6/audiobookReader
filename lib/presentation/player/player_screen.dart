import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/entities/page_content.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../playback/reader_player.dart';
import '../preview/text_preview_screen.dart';
import '../settings/settings_screen.dart';
import '../widgets/error_text.dart';
import '../widgets/jump_to_page_dialog.dart';
import '../widgets/page_text_view.dart';
import 'player_controls.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key, required this.bookId});
  final int bookId;

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  final _currentKey = GlobalKey();
  final _scroll = ScrollController();
  int? _scrolledTo;
  StreamSubscription<Object>? _notices;

  ReaderPlayer get _player => ref.read(readerPlayerProvider);

  @override
  void initState() {
    super.initState();
    unawaited(_player.open(widget.bookId));
    _notices = ref.read(ttsRouterProvider).notices.listen((e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage(AppLocalizations.of(context), e))),
      );
    });
  }

  @override
  void dispose() {
    unawaited(_notices?.cancel());
    _scroll.dispose();
    super.dispose();
  }

  /// Keeps the paragraph being read in view.
  void _followCurrent(ReaderState s, PageContent page, [int attempt = 0]) {
    final idx = s.current?.globalIndex;
    if (idx == null || idx == _scrolledTo || attempt > 6) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = _currentKey.currentContext;
      if (ctx != null) {
        _scrolledTo = idx;
        unawaited(
          Scrollable.ensureVisible(
            ctx,
            alignment: 0.25,
            duration: const Duration(milliseconds: 350),
          ),
        );
      } else if (_scroll.hasClients && page.sentences.isNotEmpty) {
        // Paragraph not built yet (lazy list): jump near it, then retry.
        final para = s.current!.paragraph;
        final last = page.sentences.last.paragraph;
        final ratio = last == 0 ? 0.0 : para / last;
        _scroll.jumpTo(_scroll.position.maxScrollExtent * ratio);
        _followCurrent(s, page, attempt + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final state = ref.watch(readerStateProvider).value ?? _player.state;
    final book = state.book;

    if (book == null || book.id != widget.bookId) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final pageAsync = ref.watch(
      pageContentProvider((book.id, state.pageIndex)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.title, overflow: TextOverflow.ellipsis),
            Text(
              l.pageNofM(state.pageIndex + 1, book.pageCount),
              style: t.textTheme.bodySmall?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l.jumpToPage,
            icon: const Icon(Icons.find_in_page_outlined),
            onPressed: () async {
              final p = await showJumpToPageDialog(
                context,
                current: state.pageIndex,
                pageCount: book.pageCount,
              );
              if (p != null) await _player.jumpToPage(p);
            },
          ),
          PopupMenuButton<int>(
            onSelected: (v) => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => v == 0
                    ? TextPreviewScreen(
                        bookId: book.id,
                        initialPage: state.pageIndex,
                      )
                    : const SettingsScreen(),
              ),
            ),
            itemBuilder: (_) => [
              PopupMenuItem(value: 0, child: Text(l.textPreview)),
              PopupMenuItem(value: 1, child: Text(l.settings)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (state.error != null)
            MaterialBanner(
              content: Text(errorMessage(l, state.error!)),
              leading: const Icon(Icons.record_voice_over_outlined),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsScreen(),
                    ),
                  ),
                  child: Text(l.voices),
                ),
              ],
            ),
          if (state.finished)
            MaterialBanner(
              content: Text(l.finishedBook),
              leading: const Icon(Icons.check_circle_outline),
              actions: [const SizedBox.shrink()],
            ),
          Expanded(
            child: pageAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(errorMessage(l, e))),
              data: (page) {
                _followCurrent(state, page);
                return PageTextView(
                  key: ValueKey(page.pageIndex),
                  page: page,
                  controller: _scroll,
                  currentGlobalIndex: state.current?.globalIndex,
                  currentKey: _currentKey,
                  onSentenceTap: (s) async {
                    await _player.seekTo(s.globalIndex);
                    await _player.play();
                  },
                );
              },
            ),
          ),
          PlayerControls(state: state, player: _player),
        ],
      ),
    );
  }
}
