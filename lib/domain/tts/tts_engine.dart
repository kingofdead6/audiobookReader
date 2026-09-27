import '../entities/app_settings.dart';
import '../entities/lang.dart';

class TtsVoice {
  const TtsVoice({required this.id, required this.name, required this.lang});

  /// Engine-specific identifier stored in settings.
  final String id;

  /// Human-readable label.
  final String name;
  final Lang lang;
}

/// A text-to-speech backend. Engines render one chunk of text to a WAV file;
/// the player streams those files, so every engine gets background playback,
/// speed control and prefetching for free.
abstract interface class TtsEngine {
  TtsEngineId get id;

  Future<void> init();

  /// Whether this engine can speak [lang] right now (voice/model installed).
  Future<bool> supports(Lang lang);

  Future<List<TtsVoice>> voices(Lang lang);

  /// Renders [text] in [lang] into a WAV file at [outPath].
  /// Throws `AppException` on failure.
  Future<void> synthesize(
    String text,
    Lang lang, {
    required String outPath,
    String? voiceId,
  });

  Future<void> dispose();
}
