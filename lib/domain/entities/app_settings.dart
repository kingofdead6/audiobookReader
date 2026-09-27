import 'lang.dart';

enum AppThemeMode { dark, light, system }

/// Which TTS implementation voices a language.
enum TtsEngineId { system, sherpa }

/// User preferences. Immutable; update with [copyWith].
class AppSettings {
  const AppSettings({
    this.themeMode = AppThemeMode.dark,
    this.localeCode,
    this.engines = const {
      Lang.en: TtsEngineId.system,
      Lang.ar: TtsEngineId.system,
    },
    this.voices = const {},
    this.speed = 1.0,
    this.voicePromptDismissed = false,
  });

  final AppThemeMode themeMode;

  /// 'en', 'ar' or null to follow the system.
  final String? localeCode;
  final Map<Lang, TtsEngineId> engines;

  /// Voice id per language and engine, e.g. {'en.system': 'en-us-x-iol-local'}.
  final Map<String, String> voices;

  /// Playback speed 0.5–2.0.
  final double speed;

  /// The first-launch "download natural voices" prompt was dismissed.
  final bool voicePromptDismissed;

  TtsEngineId engineFor(Lang lang) => engines[lang] ?? TtsEngineId.system;
  String? voiceFor(Lang lang, TtsEngineId engine) =>
      voices[voiceKey(lang, engine)];

  static String voiceKey(Lang lang, TtsEngineId engine) =>
      '${lang.name}.${engine.name}';

  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? Function()? localeCode,
    Map<Lang, TtsEngineId>? engines,
    Map<String, String>? voices,
    double? speed,
    bool? voicePromptDismissed,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    localeCode: localeCode != null ? localeCode() : this.localeCode,
    engines: engines ?? this.engines,
    voices: voices ?? this.voices,
    speed: speed ?? this.speed,
    voicePromptDismissed: voicePromptDismissed ?? this.voicePromptDismissed,
  );

  // --- flat key/value (de)serialization for the settings table ---

  Map<String, String> toMap() => {
    'theme': themeMode.name,
    'locale': localeCode ?? '',
    for (final e in engines.entries) 'engine.${e.key.name}': e.value.name,
    for (final e in voices.entries) 'voice.${e.key}': e.value,
    'speed': speed.toString(),
    'voicePromptDismissed': voicePromptDismissed.toString(),
  };

  factory AppSettings.fromMap(Map<String, String> m) {
    T byName<T extends Enum>(List<T> values, String? name, T fallback) =>
        values.where((v) => v.name == name).firstOrNull ?? fallback;
    return AppSettings(
      themeMode: byName(AppThemeMode.values, m['theme'], AppThemeMode.dark),
      localeCode: (m['locale']?.isEmpty ?? true) ? null : m['locale'],
      engines: {
        for (final l in Lang.values)
          l: byName(
            TtsEngineId.values,
            m['engine.${l.name}'],
            TtsEngineId.system,
          ),
      },
      voices: {
        for (final e in m.entries)
          if (e.key.startsWith('voice.')) e.key.substring(6): e.value,
      },
      speed: (double.tryParse(m['speed'] ?? '') ?? 1.0).clamp(0.5, 2.0),
      voicePromptDismissed: m['voicePromptDismissed'] == 'true',
    );
  }
}
