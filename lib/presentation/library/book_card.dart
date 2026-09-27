import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/book.dart';
import '../../l10n/gen/app_localizations.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onPreview,
    required this.onDelete,
  });

  final Book book;
  final VoidCallback onTap;
  final VoidCallback onPreview;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final percent = (book.progress * 100).round();

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _Cover(book: book),
                  PositionedDirectional(
                    top: 4,
                    end: 4,
                    child: _Menu(onPreview: onPreview, onDelete: onDelete),
                  ),
                  if (book.emptyPageCount > 0)
                    PositionedDirectional(
                      bottom: 6,
                      start: 6,
                      child: Tooltip(
                        message: l.pagesWithoutText(book.emptyPageCount),
                        child: CircleAvatar(
                          radius: 13,
                          backgroundColor: t.colorScheme.errorContainer,
                          child: Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: t.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            LinearProgressIndicator(value: book.progress, minHeight: 3),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.percentRead(percent),
                    style: t.textTheme.bodySmall?.copyWith(
                      color: t.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final path = book.coverPath;
    if (path != null) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (_, _, _) => _placeholder(t),
      );
    }
    return _placeholder(t);
  }

  Widget _placeholder(ThemeData t) => ColoredBox(
    color: t.colorScheme.surfaceContainerHighest,
    child: Center(
      child: Text(
        book.title.characters.take(1).toString().toUpperCase(),
        style: t.textTheme.displaySmall?.copyWith(color: t.colorScheme.primary),
      ),
    ),
  );
}

class _Menu extends StatelessWidget {
  const _Menu({required this.onPreview, required this.onDelete});
  final VoidCallback onPreview;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      child: PopupMenuButton<int>(
        iconColor: Colors.white,
        iconSize: 20,
        padding: EdgeInsets.zero,
        onSelected: (v) => v == 0 ? onPreview() : onDelete(),
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 0,
            child: ListTile(
              leading: const Icon(Icons.article_outlined),
              title: Text(l.textPreview),
            ),
          ),
          PopupMenuItem(
            value: 1,
            child: ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(l.deleteBook),
            ),
          ),
        ],
      ),
    );
  }
}
