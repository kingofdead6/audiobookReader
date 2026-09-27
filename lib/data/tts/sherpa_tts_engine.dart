import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:sherpa_onnx/sherpa_onnx.dart' as so;

import '../../core/errors.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/lang.dart';
import '../../domain/tts/tts_engine.dart';
import '../models/model_catalog.dart';
import '../models/model_manager.dart';

/// On-device neural TTS with sherpa-onnx: Kokoro for English, Piper
/// `ar_JO-kareem` for Arabic (plus an optional fast Piper English voice).
///
/// Each model runs in its own long-lived isolate because generation is a
/// blocking FFI call. Models load lazily on first use. If an isolate dies
/// or generation fails, the error propagates and `TtsRouter` falls back to
/// the system engine.
///
/// Voice ids are `"<modelId>:<speakerId>"`, e.g. `kokoro-en-v1:3`.
class SherpaTtsEngine implements TtsEngine {
  SherpaTtsEngine({required this.models});

  final ModelManager models;
  final _workers = <String, Future<_Worker>>{};

  @override
  TtsEngineId get id => TtsEngineId.sherpa;

  @override
  Future<void> init() async {
    for (final m in voiceModels) {
      await models.checkInstalled(m);
    }
  }

  List<VoiceModel> _installed(Lang lang) => [
    for (final m in voiceModels)
      if (m.lang == lang && models.isInstalledSync(m)) m,
  ];

  @override
  Future<bool> supports(Lang lang) async => _installed(lang).isNotEmpty;

  @override
  Future<List<TtsVoice>> voices(Lang lang) async => [
    for (final m in _installed(lang))
      for (final s in m.speakers)
        TtsVoice(
          id: '${m.id}:${s.id}',
          name: '${s.name} — ${m.title}',
          lang: lang,
        ),
  ];

  /// Resolves a voice id to (model, speaker), defaulting to the first
  /// installed model for [lang] and its default speaker.
  (VoiceModel, int)? resolve(Lang lang, String? voiceId) {
    final installed = _installed(lang);
    if (installed.isEmpty) return null;
    if (voiceId != null) {
      final i = voiceId.lastIndexOf(':');
      if (i > 0) {
        final m = modelById(voiceId.substring(0, i));
        final sid = int.tryParse(voiceId.substring(i + 1));
        if (m != null && sid != null && installed.contains(m)) return (m, sid);
      }
    }
    final m = installed.first;
    return (m, m.defaultSpeaker);
  }

  @override
  Future<void> synthesize(
    String text,
    Lang lang, {
    required String outPath,
    String? voiceId,
  }) async {
    final target = resolve(lang, voiceId);
    if (target == null) {
      throw AppException(AppErrorKind.languageUnavailable, lang.name);
    }
    final (model, sid) = target;
    final worker = await (_workers[model.id] ??= _spawn(model));
    try {
      await worker.generate(text, sid, outPath);
    } on AppException {
      // A dead worker is respawned on the next call.
      if (worker.dead) unawaited(_workers.remove(model.id));
      rethrow;
    }
  }

  Future<_Worker> _spawn(VoiceModel m) async {
    try {
      return await _Worker.spawn(_configFor(m));
    } catch (e) {
      unawaited(_workers.remove(m.id));
      throw AppException(AppErrorKind.engineFailed, 'load ${m.id}: $e');
    }
  }

  so.OfflineTtsConfig _configFor(VoiceModel m) {
    String f(String rel) => models.fileOf(m, rel);
    final threads = math.max(1, m.threads);
    return so.OfflineTtsConfig(
      model: so.OfflineTtsModelConfig(
        kokoro: m.kind == ModelKind.kokoro
            ? so.OfflineTtsKokoroModelConfig(
                model: f(m.modelFile),
                voices: f('voices.bin'),
                tokens: f('tokens.txt'),
                dataDir: f('espeak-ng-data'),
                lexicon: m.lexicons.map(f).join(','),
                lang: 'en-us',
              )
            : const so.OfflineTtsKokoroModelConfig(),
        vits: m.kind == ModelKind.piper
            ? so.OfflineTtsVitsModelConfig(
                model: f(m.modelFile),
                tokens: f('tokens.txt'),
                dataDir: f('espeak-ng-data'),
              )
            : const so.OfflineTtsVitsModelConfig(),
        numThreads: threads,
        debug: false,
      ),
      // (sic) the field name is misspelled in sherpa_onnx 1.13.8.
      maxNumSenetences: 1,
    );
  }

  /// Frees a model's memory, e.g. after it is deleted.
  Future<void> unload(String modelId) async {
    final w = _workers.remove(modelId);
    if (w != null) (await w).kill();
  }

  @override
  Future<void> dispose() async {
    for (final w in _workers.values) {
      try {
        (await w).kill();
      } catch (_) {}
    }
    _workers.clear();
  }
}

// ---------------------------------------------------------------- isolate

class _Request {
  const _Request(this.id, this.text, this.sid, this.outPath);
  final int id;
  final String text;
  final int sid;
  final String outPath;
}

class _Reply {
  const _Reply(this.id, this.error);
  final int id;
  final String? error;
}

/// Owns one isolate holding one loaded model.
class _Worker {
  _Worker._(this._isolate, this._send, this._port);

  final Isolate _isolate;
  final SendPort _send;
  final ReceivePort _port;
  final _pending = <int, Completer<void>>{};
  var _next = 0;
  bool dead = false;

  static Future<_Worker> spawn(so.OfflineTtsConfig config) async {
    final port = ReceivePort();
    final errors = ReceivePort();
    final exit = ReceivePort();
    final isolate = await Isolate.spawn(
      _main,
      (port.sendPort, config),
      onError: errors.sendPort,
      onExit: exit.sendPort,
      debugName: 'sherpa-tts',
    );

    final ready = Completer<SendPort>();
    late _Worker worker;
    port.listen((msg) {
      if (msg is SendPort) {
        ready.complete(msg);
      } else if (msg is String && !ready.isCompleted) {
        ready.completeError(msg); // model failed to load
      } else if (msg is _Reply) {
        final c = worker._pending.remove(msg.id);
        if (msg.error == null) {
          c?.complete();
        } else {
          c?.completeError(AppException(AppErrorKind.engineFailed, msg.error));
        }
      }
    });
    void died(Object? why) {
      if (!ready.isCompleted) ready.completeError('isolate died: $why');
      if (ready.isCompleted) {
        try {
          worker._fail('isolate died: $why');
        } catch (_) {}
      }
    }

    errors.listen(died);
    exit.listen(died);

    final send = await ready.future.timeout(const Duration(minutes: 2));
    worker = _Worker._(isolate, send, port);
    return worker;
  }

  Future<void> generate(String text, int sid, String outPath) {
    if (dead) {
      return Future.error(
        const AppException(AppErrorKind.engineFailed, 'worker dead'),
      );
    }
    final id = _next++;
    final c = _pending[id] = Completer<void>();
    _send.send(_Request(id, text, sid, outPath));
    return c.future.timeout(
      const Duration(minutes: 3),
      onTimeout: () {
        _pending.remove(id);
        throw const AppException(AppErrorKind.engineFailed, 'timeout');
      },
    );
  }

  void _fail(String why) {
    dead = true;
    for (final c in _pending.values) {
      c.completeError(AppException(AppErrorKind.engineFailed, why));
    }
    _pending.clear();
  }

  void kill() {
    _fail('killed');
    _port.close();
    _isolate.kill(priority: Isolate.immediate);
  }

  static void _main((SendPort, so.OfflineTtsConfig) args) {
    final (reply, config) = args;
    final so.OfflineTts tts;
    try {
      so.initBindings();
      tts = so.OfflineTts(config);
    } catch (e) {
      reply.send('$e');
      return;
    }
    final inbox = ReceivePort();
    reply.send(inbox.sendPort);
    inbox.listen((msg) {
      if (msg is! _Request) return;
      try {
        final audio = tts.generate(text: msg.text, sid: msg.sid, speed: 1.0);
        if (audio.samples.isEmpty) {
          reply.send(_Reply(msg.id, 'empty audio'));
          return;
        }
        final ok = so.writeWave(
          filename: msg.outPath,
          samples: audio.samples,
          sampleRate: audio.sampleRate,
        );
        reply.send(_Reply(msg.id, ok ? null : 'writeWave failed'));
      } catch (e) {
        reply.send(_Reply(msg.id, '$e'));
      }
    });
  }
}
