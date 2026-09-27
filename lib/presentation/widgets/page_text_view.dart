import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/entities/lang.dart';
import '../../domain/entities/page_content.dart';
import '../../domain/entities/sentence.dart';
import '../../l10n/gen/app_localizations.dart';

/// Renders a page as paragraphs. Each paragraph gets its own text direction
/// (RTL when mostly Arabic), so mixed pages lay out correctly; Flutter's
/// bidi algorithm handles embedded runs inside a paragraph.
class PageTextView extends StatefulWidget {
  const PageTextView({
    super.key,
    required this.page,
    this.currentGlobalIndex,
    this.tintLanguages = false,
    this.onSentenceTap,
    this.currentKey,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 32),
    this.controller,
  });

  final PageContent page;

  /// Sentence to highlight, if on this page.
  final int? currentGlobalIndex;

  /// Tint English/Arabic sentences differently (text preview).
  final bool tintLanguages;
  final void Function(Sentence)? onSentenceTap;

  /// Attached to the paragraph containing the current sentence so the
  /// player can scroll it into view.
  final GlobalKey? currentKey;
  final EdgeInsets padding;
  final ScrollController? controller;

  @override
  State<PageTextView> createState() => _PageTextViewState();
}

class _PageTextViewState extends State<PageTextView> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l = AppLocalizations.of(context);
    _disposeRecognizers();

    if (!widget.page.hasText) {
      return ListView(
        controller: widget.controller,
        padding: widget.padding,
        children: [
          Card(
            color: t.colorScheme.errorContainer,
            child: ListTile(
              leading: Icon(
                Icons.image_not_supported_outlined,
                color: t.colorScheme.onErrorContainer,
              ),
              title: Text(
                l.noTextOnPage,
                style: TextStyle(color: t.colorScheme.onErrorContainer),
              ),
            ),
          ),
        ],
      );
    }

    final base = t.textTheme.bodyLarge!.copyWith(fontSize: 19, height: 1.7);
    final paragraphs = widget.page.paragraphs;
    return ListView.builder(
      controller: widget.controller,
      padding: widget.padding,
      itemCount: paragraphs.length,
      itemBuilder: (context, i) {
        final para = paragraphs[i];
        final arabic = para.where((s) => s.lang == Lang.ar).length;
        final rtl = arabic * 2 >= para.length;
        final containsCurrent =
            widget.currentGlobalIndex != null &&
            para.any((s) => s.globalIndex == widget.currentGlobalIndex);

        final spans = <InlineSpan>[];
        for (var k = 0; k < para.length; k++) {
          final s = para[k];
          final isCurrent = s.globalIndex == widget.currentGlobalIndex;
          TapGestureRecognizer? rec;
          if (widget.onSentenceTap != null) {
            rec = TapGestureRecognizer()
              ..onTap = () => widget.onSentenceTap!(s);
            _recognizers.add(rec);
          }
          Color? bg;
          if (isCurrent) {
            bg = t.colorScheme.currentSentence;
          } else if (widget.tintLanguages) {
            bg = s.lang == Lang.ar
                ? t.colorScheme.arabicTint
                : t.colorScheme.englishTint;
          }
          spans.add(
            TextSpan(
              text: s.text,
              recognizer: rec,
              style: TextStyle(
                backgroundColor: bg,
                color: isCurrent ? t.colorScheme.onPrimaryContainer : null,
              ),
            ),
          );
          if (k < para.length - 1) spans.add(const TextSpan(text: ' '));
        }

        return Padding(
          key: containsCurrent ? widget.currentKey : null,
          padding: const EdgeInsets.only(bottom: 14),
          child: Directionality(
            textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
            child: Text.rich(
              TextSpan(style: base, children: spans),
              textAlign: TextAlign.start,
            ),
          ),
        );
      },
    );
  }
}
