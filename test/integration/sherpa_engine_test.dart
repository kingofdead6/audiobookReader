// Opt-in: runs the real sherpa-onnx engine on downloaded models.
//
//   QARI_MODELS_DIR=/path/with/extracted/models flutter test test/integration
//
// On Linux, also point the loader at the plugin's native library:
//   LD_LIBRARY_PATH=~/.pub-cache/hosted/pub.dev/sherpa_onnx_linux-1.13.8/linux/x64
//
// The directory must contain the extracted model folders named as in
// model_catalog.dart (e.g. kokoro-int8-multi-lang-v1_0/).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:qari/data/models/model_catalog.dart';
import 'package:qari/data/models/model_manager.dart';
import 'package:qari/data/tts/sherpa_tts_engine.dart';
import 'package:qari/domain/entities/lang.dart';

void main() {
  final dir = Platform.environment['QARI_MODELS_DIR'];

  group('SherpaTtsEngine', () {
    late ModelManager models;
    late SherpaTtsEngine engine;
    late Directory out;

    setUpAll(() async {
      // Mark present models as installed (normally done after download).
      for (final m in voiceModels) {
        final d = Directory(p.join(dir!, m.dirName));
        if (d.existsSync()) {
          File(p.join(d.path, '.qari_installed')).writeAsStringSync(m.sha256);
        }
      }
      models = ModelManager(modelsDir: dir!, freeBytes: (_) async => null);
      engine = SherpaTtsEngine(models: models);
      await engine.init();
      out = await Directory.systemTemp.createTemp('qari_tts');
    });

    tearDownAll(() async {
      await engine.dispose();
      await out.delete(recursive: true);
    });

    Future<int> synth(String text, Lang lang, [String? voice]) async {
      final path = p.join(
        out.path,
        '${DateTime.now().microsecondsSinceEpoch}.wav',
      );
      await engine.synthesize(text, lang, outPath: path, voiceId: voice);
      return File(path).lengthSync();
    }

    test('English with Kokoro (default voice and a chosen voice)', () async {
      expect(await engine.supports(Lang.en), isTrue);
      expect(
        await synth('Hello, this is Qari reading your book.', Lang.en),
        greaterThan(20000),
      );
      expect(
        await synth('A British voice.', Lang.en, 'kokoro-en-v1:26'),
        greaterThan(10000),
      );
    }, timeout: const Timeout(Duration(minutes: 3)));

    test('Arabic with Piper Kareem', () async {
      expect(await engine.supports(Lang.ar), isTrue);
      expect(
        await synth('ذهب الولد إلى المدرسة في الصباح الباكر.', Lang.ar),
        greaterThan(20000),
      );
    }, timeout: const Timeout(Duration(minutes: 3)));

    test('voices list Kokoro speakers', () async {
      final v = await engine.voices(Lang.en);
      expect(v.map((e) => e.id), contains('kokoro-en-v1:3'));
    });
  }, skip: dir == null ? 'set QARI_MODELS_DIR to run' : false);
}
