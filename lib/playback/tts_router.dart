import 'dart:async';

import '../core/errors.dart';
import '../domain/entities/app_settings.dart';
import '../domain/entities/lang.dart';
import '../domain/tts/tts_engine.dart';

/// Picks the engine and voice for each language from the settings and falls
/// back to the system engine when the preferred engine is missing or fails.
/// After a failure the engine stays disabled for the rest of the session.
class TtsRouter {
  TtsRouter({required this.engines, required this.settings})
    : assert(engines.containsKey(TtsEngineId.system));

  final Map<TtsEngineId, TtsEngine> engines;
  final AppSettings Function() settings;

  final _disabled = <TtsEngineId>{};
  final _notices = StreamController<AppException>.broadcast();

  /// User-visible events such as "engine failed, switched to system voice".
  Stream<AppException> get notices => _notices.stream;

  TtsEngine get _system => engines[TtsEngineId.system]!;

  /// The engine that will actually be used for [lang].
  Future<TtsEngineId> engineFor(Lang lang) async {
    final wanted = settings().engineFor(lang);
    if (wanted == TtsEngineId.system || _disabled.contains(wanted)) {
      return TtsEngineId.system;
    }
    final engine = engines[wanted];
    if (engine == null) return TtsEngineId.system;
    try {
      return await engine.supports(lang) ? wanted : TtsEngineId.system;
    } catch (_) {
      return TtsEngineId.system;
    }
  }

  /// Identifies the voice configuration; cached audio from another
  /// configuration must not be reused.
  String fingerprint() {
    final s = settings();
    return [
      for (final l in Lang.values)
        '${s.engineFor(l).name}:${s.voiceFor(l, s.engineFor(l)) ?? ''}',
      ..._disabled.map((e) => 'off:${e.name}'),
    ].join(';');
  }

  Future<void> synthesize(String text, Lang lang, String outPath) async {
    final id = await engineFor(lang);
    final engine = engines[id]!;
    try {
      await engine.synthesize(
        text,
        lang,
        outPath: outPath,
        voiceId: settings().voiceFor(lang, id),
      );
    } on Object catch (e) {
      if (id == TtsEngineId.system) rethrow;
      // Engine crash or bad model: permanently fall back for this session.
      _disabled.add(id);
      _notices.add(AppException(AppErrorKind.engineFailed, '$e'));
      await _system.synthesize(
        text,
        lang,
        outPath: outPath,
        voiceId: settings().voiceFor(lang, TtsEngineId.system),
      );
    }
  }

  /// Re-enables engines, e.g. after the user re-downloads a model.
  void resetFailures() => _disabled.clear();

  Future<void> dispose() async {
    await _notices.close();
    for (final e in engines.values) {
      await e.dispose();
    }
  }
}
