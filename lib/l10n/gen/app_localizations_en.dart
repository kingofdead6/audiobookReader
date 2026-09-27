// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Qari';

  @override
  String get library => 'Library';

  @override
  String get importPdf => 'Import PDF';

  @override
  String get emptyLibraryTitle => 'No books yet';

  @override
  String get emptyLibraryHint =>
      'Import a PDF book and Qari will read it aloud in English and Arabic.';

  @override
  String get importing => 'Importing…';

  @override
  String get importStageCopying => 'Copying file…';

  @override
  String importStageExtracting(int done, int total) {
    return 'Extracting text: page $done of $total';
  }

  @override
  String get importStageProcessing => 'Cleaning text and splitting sentences…';

  @override
  String get importStageSaving => 'Saving…';

  @override
  String importDone(String title) {
    return 'Imported “$title”';
  }

  @override
  String get importFailed => 'Import failed';

  @override
  String get errorCorruptPdf =>
      'This PDF could not be opened. The file may be damaged.';

  @override
  String get errorPasswordProtected =>
      'This PDF is password-protected. Remove the password and try again.';

  @override
  String get errorNoTextLayer =>
      'No text found in this PDF. It looks like a scanned book; OCR is not supported yet.';

  @override
  String errorAlreadyImported(String title) {
    return 'This book is already in your library: $title';
  }

  @override
  String get errorLowStorage => 'Not enough free storage on the device.';

  @override
  String get errorDownloadFailed =>
      'Download failed. Check your connection and try again.';

  @override
  String get errorChecksum => 'The downloaded file is corrupted. Please retry.';

  @override
  String get errorEngineFailed =>
      'The voice engine failed; switched to the system voice.';

  @override
  String errorLanguageUnavailable(String language) {
    return 'No $language voice is installed on this phone. Install it in Android Settings → Text-to-speech, or download the Qari voice.';
  }

  @override
  String get errorUnknown => 'Something went wrong.';

  @override
  String get textPreview => 'Text preview';

  @override
  String pageN(int page) {
    return 'Page $page';
  }

  @override
  String pageNofM(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String get noTextOnPage =>
      'No text on this page (scanned image or blank). It will be skipped.';

  @override
  String pagesWithoutText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages have no text and will be skipped',
      one: '1 page has no text and will be skipped',
    );
    return '$_temp0';
  }

  @override
  String get deleteBook => 'Delete';

  @override
  String deleteBookConfirm(String title) {
    return 'Delete “$title” from the library?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get retry => 'Retry';

  @override
  String get go => 'Go';

  @override
  String get settings => 'Settings';

  @override
  String get appLanguage => 'App language';

  @override
  String get followSystem => 'System default';

  @override
  String get theme => 'Theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String percentRead(int percent) {
    return '$percent% read';
  }

  @override
  String get jumpToPage => 'Jump to page';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String sentenceCount(int count) {
    return '$count sentences';
  }

  @override
  String get legendEnglish => 'English';

  @override
  String get legendArabic => 'Arabic';
}
