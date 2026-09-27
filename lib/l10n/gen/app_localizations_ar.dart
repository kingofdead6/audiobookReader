// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'قارئ';

  @override
  String get library => 'المكتبة';

  @override
  String get importPdf => 'استيراد PDF';

  @override
  String get emptyLibraryTitle => 'لا توجد كتب بعد';

  @override
  String get emptyLibraryHint =>
      'استورد كتابًا بصيغة PDF وسيقرؤه قارئ بصوت عالٍ بالعربية والإنجليزية.';

  @override
  String get importing => 'جارٍ الاستيراد…';

  @override
  String get importStageCopying => 'جارٍ نسخ الملف…';

  @override
  String importStageExtracting(int done, int total) {
    return 'استخراج النص: صفحة $done من $total';
  }

  @override
  String get importStageProcessing => 'تنظيف النص وتقسيم الجمل…';

  @override
  String get importStageSaving => 'جارٍ الحفظ…';

  @override
  String importDone(String title) {
    return 'تم استيراد «$title»';
  }

  @override
  String get importFailed => 'فشل الاستيراد';

  @override
  String get errorCorruptPdf => 'تعذّر فتح ملف PDF. قد يكون الملف تالفًا.';

  @override
  String get errorPasswordProtected =>
      'ملف PDF محمي بكلمة مرور. أزل كلمة المرور وحاول مجددًا.';

  @override
  String get errorNoTextLayer =>
      'لم يُعثر على نص في هذا الملف. يبدو أنه كتاب ممسوح ضوئيًا، والتعرّف الضوئي على النصوص غير مدعوم حاليًا.';

  @override
  String errorAlreadyImported(String title) {
    return 'هذا الكتاب موجود في مكتبتك: $title';
  }

  @override
  String get errorLowStorage => 'لا توجد مساحة تخزين كافية على الجهاز.';

  @override
  String get errorDownloadFailed =>
      'فشل التنزيل. تحقّق من الاتصال وحاول مجددًا.';

  @override
  String get errorChecksum => 'الملف الذي تم تنزيله تالف. يرجى إعادة المحاولة.';

  @override
  String get errorEngineFailed =>
      'تعطّل محرّك الصوت؛ تم التبديل إلى صوت النظام.';

  @override
  String errorLanguageUnavailable(String language) {
    return 'لا يوجد صوت $language مثبّت على هذا الهاتف. ثبّته من إعدادات أندرويد ← تحويل النص إلى كلام، أو نزّل صوت قارئ.';
  }

  @override
  String get errorUnknown => 'حدث خطأ ما.';

  @override
  String get textPreview => 'معاينة النص';

  @override
  String pageN(int page) {
    return 'صفحة $page';
  }

  @override
  String pageNofM(int page, int total) {
    return 'صفحة $page من $total';
  }

  @override
  String get noTextOnPage =>
      'لا يوجد نص في هذه الصفحة (صورة ممسوحة أو صفحة فارغة). سيتم تخطيها.';

  @override
  String pagesWithoutText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صفحة بلا نص وسيتم تخطيها',
      few: '$count صفحات بلا نص وسيتم تخطيها',
      two: 'صفحتان بلا نص وسيتم تخطيهما',
      one: 'صفحة واحدة بلا نص وسيتم تخطيها',
    );
    return '$_temp0';
  }

  @override
  String get deleteBook => 'حذف';

  @override
  String deleteBookConfirm(String title) {
    return 'حذف «$title» من المكتبة؟';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get ok => 'حسنًا';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get go => 'انتقال';

  @override
  String get settings => 'الإعدادات';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get followSystem => 'حسب النظام';

  @override
  String get theme => 'المظهر';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeSystem => 'حسب النظام';

  @override
  String percentRead(int percent) {
    return 'تمت قراءة $percent٪';
  }

  @override
  String get jumpToPage => 'الانتقال إلى صفحة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String sentenceCount(int count) {
    return '$count جملة';
  }

  @override
  String get legendEnglish => 'إنجليزي';

  @override
  String get legendArabic => 'عربي';
}
