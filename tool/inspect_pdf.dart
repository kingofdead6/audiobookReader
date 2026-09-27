// Runs Qari's extraction + cleaning pipeline on a PDF from the command line,
// so extraction quality can be checked on a desktop without a phone.
//
//   dart run tool/inspect_pdf.dart path/to/book.pdf [firstPage] [lastPage]
//
// Uses the pure-Dart build of PDFium from pdfrx_engine (downloaded and
// cached on first run), i.e. the same engine the app uses on Android.
// Set RAW=1 to also print PDFium's unprocessed text.
// ignore_for_file: avoid_print
import 'dart:io';

import 'package:pdfrx_engine/pdfrx_engine.dart';
import 'package:qari/domain/text/book_text_builder.dart';
import 'package:qari/domain/text/line_rebuilder.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('usage: dart run tool/inspect_pdf.dart file.pdf [first] [last]');
    exit(64);
  }
  final showRaw = Platform.environment['RAW'] == '1';
  await pdfrxInitialize();
  final doc = await PdfDocument.openFile(args[0]);
  final raw = <String>[];
  final rebuilt = <String>[];
  for (final page in doc.pages) {
    final t = await page.loadText();
    raw.add(t?.fullText ?? '');
    rebuilt.add(
      t == null
          ? ''
          : const LineRebuilder().rebuild(t.fullText, [
              for (final r in t.charRects)
                GlyphBox(r.left, r.top, r.right, r.bottom),
            ]),
    );
  }
  await doc.dispose();

  final pages = const BookTextBuilder().build(rebuilt);
  final first = args.length > 1 ? int.parse(args[1]) - 1 : 0;
  final last = args.length > 2 ? int.parse(args[2]) - 1 : pages.length - 1;
  for (final p in pages.sublist(first, last + 1)) {
    print(
      '════════ page ${p.pageIndex + 1} '
      '${p.hasText ? '' : '(NO TEXT LAYER - skipped)'}',
    );
    if (showRaw) print('--- PDFium raw ---\n${raw[p.pageIndex]}');
    print('--- rebuilt lines ---\n${rebuilt[p.pageIndex]}\n--- sentences ---');
    for (final s in p.sentences) {
      print('[${s.lang.name}] ¶${s.paragraph} ${s.text}');
    }
  }
}
