import 'dart:async';
import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';

import '../../core/errors.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/lang.dart';
import '../../domain/tts/tts_engine.dart';

/// Android's built-in text-to-speech via flutter_tts. Needs no download, so
/// it is the default engine until the user installs Qari's voice models.
///
/// Android renders one file at a time, so calls are serialized.
class SystemTtsEngine implements TtsEngine {
  SystemTtsEngine({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  Future<void> _queue = Future.value();
  bool _ready = false;
  Lang? _lang;
  String? _voiceId;

  @override
  TtsEngineId get id => TtsEngineId.system;

  @override
  Future<void> init() async {
    if (_ready) return;
    await _tts.awaitSynthCompletion(true);
    // flutter_tts doubles this on Android: 0.5 -> 1.0 (normal). Playback
    // speed is applied by the audio player, so synthesis stays at normal.
    await _tts.setSpeechRate(0.5);
    _ready = true;
  }

  @override
  Future<bool> supports(Lang lang) async {
    await init();
    final r = await _tts.isLanguageAvailable(lang.bcp47);
    return r == true;
  }

  @override
  Future<List<TtsVoice>> voices(Lang lang) async {
    await init();
    final raw = await _tts.getVoices;
    if (raw is! List) return const [];
    final out = <TtsVoice>[];
    for (final v in raw) {
      if (v is! Map) continue;
      final name = '${v['name'] ?? ''}';
      final locale = '${v['locale'] ?? ''}';
      if (name.isEmpty || !locale.toLowerCase().startsWith(lang.name)) continue;
      if ('${v['network_required']}' == '1') continue; // offline only
      out.add(
        TtsVoice(id: '$name|$locale', name: '$locale · $name', lang: lang),
      );
    }
    out.sort((a, b) => a.name.compareTo(b.name));
    return out;
  }

  @override
  Future<void> synthesize(
    String text,
    Lang lang, {
    required String outPath,
    String? voiceId,
  }) {
    final job = _queue.then((_) => _synth(text, lang, outPath, voiceId));
    _queue = job.catchError((_) {});
    return job;
  }

  Future<void> _synth(
    String text,
    Lang lang,
    String outPath,
    String? voiceId,
  ) async {
    await init();
    if (_lang != lang || _voiceId != voiceId) {
      final ok = await _tts.setLanguage(lang.bcp47);
      if (ok != 1 && !(await supports(lang))) {
        throw AppException(AppErrorKind.languageUnavailable, lang.name);
      }
      if (voiceId != null) {
        final parts = voiceId.split('|');
        if (parts.length == 2) {
          await _tts.setVoice({'name': parts[0], 'locale': parts[1]});
        }
      }
      _lang = lang;
      _voiceId = voiceId;
    }

    final file = File(outPath);
    if (await file.exists()) await file.delete();
    final result = await _tts
        .synthesizeToFile(text, outPath, true)
        .timeout(const Duration(seconds: 45));
    if (result != 1 || !await file.exists() || await file.length() <= 44) {
      _lang = null; // force re-configuration next time
      if (!await supports(lang)) {
        throw AppException(AppErrorKind.languageUnavailable, lang.name);
      }
      throw AppException(
        AppErrorKind.engineFailed,
        'system tts result=$result',
      );
    }
  }

  @override
  Future<void> dispose() => _tts.stop();
}
