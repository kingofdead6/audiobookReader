import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Qari'**
  String get appTitle;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @importPdf.
  ///
  /// In en, this message translates to:
  /// **'Import PDF'**
  String get importPdf;

  /// No description provided for @emptyLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'No books yet'**
  String get emptyLibraryTitle;

  /// No description provided for @emptyLibraryHint.
  ///
  /// In en, this message translates to:
  /// **'Import a PDF book and Qari will read it aloud in English and Arabic.'**
  String get emptyLibraryHint;

  /// No description provided for @importing.
  ///
  /// In en, this message translates to:
  /// **'Importing…'**
  String get importing;

  /// No description provided for @importStageCopying.
  ///
  /// In en, this message translates to:
  /// **'Copying file…'**
  String get importStageCopying;

  /// No description provided for @importStageExtracting.
  ///
  /// In en, this message translates to:
  /// **'Extracting text: page {done} of {total}'**
  String importStageExtracting(int done, int total);

  /// No description provided for @importStageProcessing.
  ///
  /// In en, this message translates to:
  /// **'Cleaning text and splitting sentences…'**
  String get importStageProcessing;

  /// No description provided for @importStageSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get importStageSaving;

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'Imported “{title}”'**
  String importDone(String title);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get importFailed;

  /// No description provided for @errorCorruptPdf.
  ///
  /// In en, this message translates to:
  /// **'This PDF could not be opened. The file may be damaged.'**
  String get errorCorruptPdf;

  /// No description provided for @errorPasswordProtected.
  ///
  /// In en, this message translates to:
  /// **'This PDF is password-protected. Remove the password and try again.'**
  String get errorPasswordProtected;

  /// No description provided for @errorNoTextLayer.
  ///
  /// In en, this message translates to:
  /// **'No text found in this PDF. It looks like a scanned book; OCR is not supported yet.'**
  String get errorNoTextLayer;

  /// No description provided for @errorAlreadyImported.
  ///
  /// In en, this message translates to:
  /// **'This book is already in your library: {title}'**
  String errorAlreadyImported(String title);

  /// No description provided for @errorLowStorage.
  ///
  /// In en, this message translates to:
  /// **'Not enough free storage on the device.'**
  String get errorLowStorage;

  /// No description provided for @errorDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Check your connection and try again.'**
  String get errorDownloadFailed;

  /// No description provided for @errorChecksum.
  ///
  /// In en, this message translates to:
  /// **'The downloaded file is corrupted. Please retry.'**
  String get errorChecksum;

  /// No description provided for @errorEngineFailed.
  ///
  /// In en, this message translates to:
  /// **'The voice engine failed; switched to the system voice.'**
  String get errorEngineFailed;

  /// No description provided for @errorLanguageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No {language} voice is installed on this phone. Install it in Android Settings → Text-to-speech, or download the Qari voice.'**
  String errorLanguageUnavailable(String language);

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorUnknown;

  /// No description provided for @textPreview.
  ///
  /// In en, this message translates to:
  /// **'Text preview'**
  String get textPreview;

  /// No description provided for @pageN.
  ///
  /// In en, this message translates to:
  /// **'Page {page}'**
  String pageN(int page);

  /// No description provided for @pageNofM.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String pageNofM(int page, int total);

  /// No description provided for @noTextOnPage.
  ///
  /// In en, this message translates to:
  /// **'No text on this page (scanned image or blank). It will be skipped.'**
  String get noTextOnPage;

  /// No description provided for @pagesWithoutText.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page has no text and will be skipped} other{{count} pages have no text and will be skipped}}'**
  String pagesWithoutText(int count);

  /// No description provided for @deleteBook.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteBook;

  /// No description provided for @deleteBookConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete “{title}” from the library?'**
  String deleteBookConfirm(String title);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get go;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get followSystem;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @percentRead.
  ///
  /// In en, this message translates to:
  /// **'{percent}% read'**
  String percentRead(int percent);

  /// No description provided for @jumpToPage.
  ///
  /// In en, this message translates to:
  /// **'Jump to page'**
  String get jumpToPage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @sentenceCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sentences'**
  String sentenceCount(int count);

  /// No description provided for @legendEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get legendEnglish;

  /// No description provided for @legendArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get legendArabic;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @previousSentence.
  ///
  /// In en, this message translates to:
  /// **'Previous sentence'**
  String get previousSentence;

  /// No description provided for @nextSentence.
  ///
  /// In en, this message translates to:
  /// **'Next sentence'**
  String get nextSentence;

  /// No description provided for @preparingVoice.
  ///
  /// In en, this message translates to:
  /// **'Preparing voice…'**
  String get preparingVoice;

  /// No description provided for @finishedBook.
  ///
  /// In en, this message translates to:
  /// **'You reached the end of the book.'**
  String get finishedBook;

  /// No description provided for @voices.
  ///
  /// In en, this message translates to:
  /// **'Voices'**
  String get voices;

  /// No description provided for @voiceFor.
  ///
  /// In en, this message translates to:
  /// **'{language} voice'**
  String voiceFor(String language);

  /// No description provided for @systemVoiceDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemVoiceDefault;

  /// No description provided for @testVoice.
  ///
  /// In en, this message translates to:
  /// **'Test voice'**
  String get testVoice;

  /// No description provided for @testSentenceEn.
  ///
  /// In en, this message translates to:
  /// **'This is how English text will sound.'**
  String get testSentenceEn;

  /// No description provided for @testSentenceAr.
  ///
  /// In en, this message translates to:
  /// **'هكذا سيبدو النص العربي عند قراءته.'**
  String get testSentenceAr;

  /// No description provided for @ttsSettings.
  ///
  /// In en, this message translates to:
  /// **'Android text-to-speech settings'**
  String get ttsSettings;

  /// No description provided for @noVoicesFound.
  ///
  /// In en, this message translates to:
  /// **'No offline voices found for this language.'**
  String get noVoicesFound;

  /// No description provided for @tapSentenceHint.
  ///
  /// In en, this message translates to:
  /// **'Tip: tap any sentence to start reading from there.'**
  String get tapSentenceHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
