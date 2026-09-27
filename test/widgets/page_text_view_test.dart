import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qari/domain/entities/lang.dart';
import 'package:qari/domain/entities/page_content.dart';
import 'package:qari/domain/entities/sentence.dart';
import 'package:qari/l10n/gen/app_localizations.dart';
import 'package:qari/presentation/widgets/page_text_view.dart';

Sentence s(int i, int para, String text, Lang lang) => Sentence(
  pageIndex: 0,
  indexInPage: i,
  globalIndex: i,
  paragraph: para,
  text: text,
  lang: lang,
);

Widget host(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  final page = PageContent(
    pageIndex: 0,
    hasText: true,
    sentences: [
      s(0, 0, 'Hello world.', Lang.en),
      s(1, 1, 'ذهب الولد إلى المدرسة.', Lang.ar),
      s(2, 1, 'هل عاد؟', Lang.ar),
    ],
  );

  testWidgets('paragraph direction follows its language', (tester) async {
    await tester.pumpWidget(host(PageTextView(page: page)));
    final en = tester.widget<Directionality>(
      find
          .ancestor(
            of: find.textContaining('Hello', findRichText: true),
            matching: find.byType(Directionality),
          )
          .first,
    );
    final ar = tester.widget<Directionality>(
      find
          .ancestor(
            of: find.textContaining('ذهب', findRichText: true),
            matching: find.byType(Directionality),
          )
          .first,
    );
    expect(en.textDirection, TextDirection.ltr);
    expect(ar.textDirection, TextDirection.rtl);
  });

  testWidgets('tapping a sentence reports it', (tester) async {
    Sentence? tapped;
    await tester.pumpWidget(
      host(PageTextView(page: page, onSentenceTap: (x) => tapped = x)),
    );
    await tester.tapOnText(find.textRange.ofSubstring('Hello'));
    expect(tapped?.globalIndex, 0);
  });

  testWidgets('page without text shows the skip warning', (tester) async {
    await tester.pumpWidget(
      host(
        const PageTextView(
          page: PageContent(pageIndex: 3, hasText: false, sentences: []),
        ),
      ),
    );
    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
  });
}
