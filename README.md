# Qari · قارئ

Offline Android audiobook reader for PDF books in **English and Arabic**
(including mixed pages). Everything runs on the device: no servers, no API
keys, no analytics.

## Status

| Milestone | Scope | State |
|---|---|---|
| M1 | PDF import, text extraction, Arabic normalization, text preview | ✅ |
| M2 | System TTS playback, sentence streaming, language switching, highlighting | ✅ |
| M3 | Voice model download manager + sherpa-onnx (Kokoro EN, Piper AR) | ✅ |
| M4 | Background playback, resume, speed, sleep timer, library polish | ✅ |

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

## Testing on a real phone

Enable *Developer options → USB debugging*, connect the phone, then
`flutter run --release`. Make test PDFs from any HTML page with Chrome's
*Print → Save as PDF* if you have no mixed-language book at hand.

**M1 – import & extraction**
1. Tap **Import PDF**, pick an English PDF: progress shows page by page, the
   book appears with its first-page cover and 0 %.
2. Book menu (⋮) → **Text preview**: swipe pages; English sentences are
   tinted one colour, Arabic another; running headers/page numbers are gone.
3. Import an Arabic PDF (ideally one with diacritics) and a mixed one; Arabic
   paragraphs are right-aligned and read correctly (no reversed words, no
   stray diacritic lines).
4. Import a scanned PDF → "No text found… OCR is not supported". A book with
   a few image-only pages imports with a ⚠ badge; those pages show a warning.
5. Import the same file twice → "already in your library". A renamed
   non-PDF / damaged file → "could not be opened".

**M2 – system voice playback**
1. Install voices: Android *Settings → Text-to-speech → Speech Services by
   Google → Install voice data* → English and Arabic.
2. Tap a book → player. Press ▶: the current sentence is highlighted and
   followed; there is no gap between sentences.
3. Mixed page: the voice switches between English and Arabic per sentence.
4. ⏮ / ⏭ move by one sentence; tap any sentence to read from it; the page
   icon jumps to a page (image-only pages are skipped).
5. Settings → Voices: pick a different voice per language and **Test voice**.
6. Remove the Arabic voice data → playing Arabic shows a banner explaining
   how to install it.

**M3 – Qari voices (offline neural)**
1. Library shows **Get natural voices** → **Download**. Download Kokoro and
   Kareem: progress in MB, then "Verifying…", "Unpacking…" (1–2 min).
2. Toggle airplane mode mid-download → it fails with **Retry**/**Resume**,
   continuing from where it stopped. With too little storage you get a
   clear message before anything is downloaded.
3. After install, Settings shows **Qari (offline)** selected for that
   language; play a book in airplane mode — everything works offline.
4. Pick another Kokoro speaker (e.g. *George · UK ♂*), test it.
5. Delete a model in Settings → Voice models → that language falls back to
   the system voice automatically.

**M4 – background & polish**
1. Start playback, lock the phone: reading continues; the lock screen and
   notification show the book with ⏮ ⏯ ⏭ controls. Headset buttons work.
2. Unplug headphones → pauses. Incoming call → pauses, resumes after.
3. Speed button (1.0×): 0.5×–2× without pitch change; remembered.
4. Moon button: sleep in 5 min / end of page; the remaining time is shown.
5. Leave the book mid-page, kill the app, reopen: the library shows the
   mini-player and the progress %; opening the book resumes on the exact
   sentence.
6. Switch the app language to العربية in Settings: the whole UI is RTL.

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

### Voices

| Engine | English | Arabic | Download |
|---|---|---|---|
| System (flutter_tts → Android TTS) | installed Android voice | installed Android voice | none |
| Qari / sherpa-onnx 1.13.8 | Kokoro v1.0 int8, 28 voices (132 MB) | Piper `ar_JO-kareem-medium` (67 MB) | on request |
| Qari / sherpa-onnx (optional) | Piper `en_US-lessac-medium`, fast (67 MB) | — | on request |

Models come from the official
[sherpa-onnx `tts-models` release](https://github.com/k2-fsa/sherpa-onnx/releases/tag/tts-models)
and are stored in the app's documents directory (`models/`). Each download
is resumable (HTTP Range), checked against a pinned size and SHA-256
(`lib/data/models/model_catalog.dart`), unpacked in a background isolate and
only then marked installed. On a new phone, download them again from
Settings → Voice models.

If the neural engine fails (bad model, isolate crash) the router switches
that language to the system voice for the rest of the session and shows a
notice.

Measured on the 4-core build VM (x86, sherpa-onnx Dart, 4 threads):
Kokoro real-time factor ≈ 1.1, Piper ≈ 0.05. Phones differ; if Kokoro cannot
keep up on an older phone (you hear pauses between sentences), download the
fast Piper English voice and pick it in Settings.

Run the real engine on a desktop (after extracting the archives into a folder):

```bash
LD_LIBRARY_PATH=~/.pub-cache/hosted/pub.dev/sherpa_onnx_linux-1.13.8/linux/x64 \
QARI_MODELS_DIR=/path/to/models flutter test test/integration
```

### Package choices

- **pdfrx** (MIT, PDFium) over syncfusion_flutter_pdf: Syncfusion needs a
  (community) license and is not open source; PDFium is Chrome's engine and
  also renders the cover.
- **Drift** (SQLite) over Hive: books → pages → sentences is relational; the
  player reads "sentences 412–414 of book 3" by index without loading the
  book, and a book's text is written in one transaction.
- **Riverpod 3** for state, **flutter_localizations/intl** for EN/AR UI.
