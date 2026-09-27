/// Languages the reader can speak. New languages are added here and in
/// `LanguageDetector`, then routed to an engine in the TTS router.
enum Lang {
  en,
  ar;

  bool get isRtl => this == Lang.ar;

  /// BCP-47 tag used for the Android system TTS.
  String get bcp47 => switch (this) {
    Lang.en => 'en-US',
    Lang.ar => 'ar',
  };

  static Lang fromCode(int code) => Lang.values[code];
}
