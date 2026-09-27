/// Error kinds the UI knows how to explain to the user (see
/// `presentation/widgets/error_text.dart`).
enum AppErrorKind {
  corruptPdf,
  passwordProtected,
  noTextLayer,
  alreadyImported,
  lowStorage,
  downloadFailed,
  checksumMismatch,
  engineFailed,
  languageUnavailable,
  unknown,
}

class AppException implements Exception {
  const AppException(this.kind, [this.detail]);

  final AppErrorKind kind;

  /// Technical detail for logs / "more info"; not localized.
  final String? detail;

  @override
  String toString() =>
      'AppException(${kind.name}${detail == null ? '' : ': $detail'})';
}
