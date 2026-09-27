import '../../core/errors.dart';
import '../../l10n/gen/app_localizations.dart';

/// Localized, user-facing message for any error thrown by the app.
String errorMessage(AppLocalizations l, Object error) {
  if (error is! AppException) return l.errorUnknown;
  return switch (error.kind) {
    AppErrorKind.corruptPdf => l.errorCorruptPdf,
    AppErrorKind.passwordProtected => l.errorPasswordProtected,
    AppErrorKind.noTextLayer => l.errorNoTextLayer,
    AppErrorKind.alreadyImported => l.errorAlreadyImported(error.detail ?? ''),
    AppErrorKind.lowStorage => l.errorLowStorage,
    AppErrorKind.downloadFailed => l.errorDownloadFailed,
    AppErrorKind.checksumMismatch => l.errorChecksum,
    AppErrorKind.engineFailed => l.errorEngineFailed,
    AppErrorKind.languageUnavailable => l.errorLanguageUnavailable(
      error.detail ?? '',
    ),
    AppErrorKind.unknown => l.errorUnknown,
  };
}
