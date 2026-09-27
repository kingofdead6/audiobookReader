import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/gen/app_localizations.dart';

/// Returns a zero-based page index, or null if cancelled.
Future<int?> showJumpToPageDialog(
  BuildContext context, {
  required int current,
  required int pageCount,
}) {
  final l = AppLocalizations.of(context);
  final controller = TextEditingController(text: '${current + 1}');
  int? parse() {
    final v = int.tryParse(controller.text.trim());
    if (v == null || v < 1 || v > pageCount) return null;
    return v - 1;
  }

  return showDialog<int>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(l.jumpToPage),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(helperText: '1 – $pageCount'),
        onSubmitted: (_) {
          final p = parse();
          if (p != null) Navigator.pop(c, p);
        },
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: Text(l.cancel)),
        FilledButton(
          onPressed: () {
            final p = parse();
            if (p != null) Navigator.pop(c, p);
          },
          child: Text(l.go),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}
