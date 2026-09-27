import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../l10n/gen/app_localizations.dart';
import '../widgets/error_text.dart';
import '../widgets/jump_to_page_dialog.dart';
import '../widgets/page_text_view.dart';

/// Shows the cleaned, split text page by page so the user can judge
/// extraction quality. Sentences are tinted by detected language.
class TextPreviewScreen extends ConsumerStatefulWidget {
  const TextPreviewScreen({
    super.key,
    required this.bookId,
    this.initialPage = 0,
  });

  final int bookId;
  final int initialPage;

  @override
  ConsumerState<TextPreviewScreen> createState() => _TextPreviewScreenState();
}

class _TextPreviewScreenState extends ConsumerState<TextPreviewScreen> {
  late final PageController _pager = PageController(
    initialPage: widget.initialPage,
  );
  late int _page = widget.initialPage;

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final book = ref.watch(bookProvider(widget.bookId)).value;
    final total = book?.pageCount ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.textPreview),
            if (book != null)
              Text(
                book.title,
                style: t.textTheme.bodySmall?.copyWith(
                  color: t.colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l.jumpToPage,
            icon: const Icon(Icons.find_in_page_outlined),
            onPressed: total == 0
                ? null
                : () async {
                    final p = await showJumpToPageDialog(
                      context,
                      current: _page,
                      pageCount: total,
                    );
                    if (p != null) _pager.jumpToPage(p);
                  },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Text(total == 0 ? '' : l.pageNofM(_page + 1, total)),
                const Spacer(),
                _Legend(
                  color: t.colorScheme.englishTint,
                  label: l.legendEnglish,
                ),
                const SizedBox(width: 12),
                _Legend(color: t.colorScheme.arabicTint, label: l.legendArabic),
              ],
            ),
          ),
        ),
      ),
      body: total == 0
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: _pager,
              itemCount: total,
              onPageChanged: (p) => setState(() => _page = p),
              itemBuilder: (context, index) {
                final page = ref.watch(
                  pageContentProvider((widget.bookId, index)),
                );
                return page.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(errorMessage(l, e))),
                  data: (content) =>
                      PageTextView(page: content, tintLanguages: true),
                );
              },
            ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}
