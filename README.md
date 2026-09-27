# Qari · قارئ

Offline Android audiobook reader for PDF books in **English and Arabic**
(including mixed pages). Everything runs on the device: no servers, no API
keys, no analytics.

## Status

| Milestone | Scope | State |
|---|---|---|
| M1 | PDF import, text extraction, Arabic normalization, text preview | ✅ |
| M2 | System TTS playback, sentence streaming, language switching, highlighting | ✅ |
| M3 | Voice model download manager + sherpa-onnx (Kokoro EN, Piper AR) | ⏳ |
| M4 | Background playback, resume, speed, sleep timer, library polish | ⏳ |

## Requirements

- Flutter **3.47.x stable** (Dart 3.13) — `pdfrx 2.6` requires Flutter ≥ 3.47
- Android SDK (API 36 platform via Android Studio) and an Android 7.0+ phone
  (minSdk 24)

## Run on a phone

```bash
flutter pub get
flutter devices                 # phone must show up (USB debugging on)
flutter run --release           # or: flutter run   (debug, slower TTS later)
```

Build installable APKs (one per CPU architecture, much smaller than a fat APK):

```bash
flutter build apk --release --split-per-abi
# most phones: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

## Tests

```bash
flutter test
```

Unit tests cover language detection, Arabic normalization (presentation
forms, visual-order lines, ligatures, tatweel, control characters), the
sentence splitter (English abbreviations, Arabic punctuation, length cap),
the page cleaner (running headers/footers, page numbers, hyphenation,
paragraphs) and the PDF line rebuilder (real glyph boxes from a Chrome PDF).

### Checking extraction on a desktop

The same PDFium engine is available to plain Dart, so you can inspect how a
book will be cleaned and split without a phone:

```bash
dart run tool/inspect_pdf.dart path/to/book.pdf 1 5      # pages 1–5
RAW=1 dart run tool/inspect_pdf.dart book.pdf 3 3       # also show PDFium's raw text
```

## Architecture

```
lib/
  domain/        pure Dart: entities, repository interfaces, text pipeline, use cases
    text/        language_detector, arabic_normalizer, line_rebuilder,
                 text_cleaner, sentence_splitter, book_text_builder
  data/          Drift database, pdfrx extraction, repositories, file paths
  presentation/  screens and widgets (library, text preview, settings)
  app/           Riverpod providers, theme, MaterialApp
  l10n/          English + Arabic strings (ARB), generated code in l10n/gen
tool/            inspect_pdf.dart, presentation-form table generator
```

Text pipeline (runs once at import, result cached in SQLite):

1. **pdfrx / PDFium** returns characters with their boxes.
2. **LineRebuilder** re-assembles lines from geometry: PDFium splits Arabic
   diacritics into separate lines, reverses lam-alef ligatures, misplaces
   punctuation and drops spaces; ordering right-to-left lines by glyph
   position (keeping Latin/number runs left-to-right) fixes this.
3. **ArabicNormalizer**: presentation forms (U+FB50–U+FEFF) → base letters,
   visual-order (reversed) lines detected and flipped, tatweel and bidi /
   zero-width controls removed, split word endings re-joined.
4. **TextCleaner**: running headers/footers and page numbers removed,
   hyphenated words merged, lines merged into paragraphs; pages without a
   text layer are flagged (scanned books: OCR is out of scope for v1).
5. **SentenceSplitter**: `. ! ? … ؟ ۔`, English abbreviations, chunks capped
   at 280 characters (split at `, ; : ، ؛`, then spaces).
6. **LanguageDetector**: Arabic vs Latin script per sentence; long foreign
   runs inside a sentence become separate chunks for the other voice.

### Package choices

- **pdfrx** (MIT, PDFium) over syncfusion_flutter_pdf: Syncfusion needs a
  (community) license and is not open source; PDFium is Chrome's engine and
  also renders the cover.
- **Drift** (SQLite) over Hive: books → pages → sentences is relational; the
  player reads "sentences 412–414 of book 3" by index without loading the
  book, and a book's text is written in one transaction.
- **Riverpod 3** for state, **flutter_localizations/intl** for EN/AR UI.
