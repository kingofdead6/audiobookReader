import 'package:flutter_test/flutter_test.dart';
import 'package:qari/core/errors.dart';
import 'package:qari/domain/entities/app_settings.dart';
import 'package:qari/domain/entities/lang.dart';
import 'package:qari/domain/tts/tts_engine.dart';
import 'package:qari/playback/tts_router.dart';

class FakeEngine implements TtsEngine {
  FakeEngine(this.id, {this.supported = const {Lang.en, Lang.ar}});

  @override
  final TtsEngineId id;
  Set<Lang> supported;
  bool fail = false;
  final calls = <(String, Lang, String?)>[];

  @override
  Future<void> init() async {}
  @override
  Future<bool> supports(Lang lang) async => supported.contains(lang);
  @override
  Future<List<TtsVoice>> voices(Lang lang) async => const [];
  @override
  Future<void> synthesize(
    String text,
    Lang lang, {
    required String outPath,
    String? voiceId,
  }) async {
    if (fail) throw const AppException(AppErrorKind.engineFailed, 'boom');
    calls.add((text, lang, voiceId));
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  late FakeEngine system;
  late FakeEngine sherpa;
  late AppSettings settings;
  late TtsRouter router;

  setUp(() {
    system = FakeEngine(TtsEngineId.system);
    sherpa = FakeEngine(TtsEngineId.sherpa);
    settings = const AppSettings(
      engines: {Lang.en: TtsEngineId.sherpa, Lang.ar: TtsEngineId.system},
      voices: {'en.sherpa': '3', 'ar.system': 'ar-voice|ar'},
    );
    router = TtsRouter(
      engines: {TtsEngineId.system: system, TtsEngineId.sherpa: sherpa},
      settings: () => settings,
    );
  });

  test('routes each language to its configured engine and voice', () async {
    await router.synthesize('Hello', Lang.en, '/tmp/a.wav');
    await router.synthesize('مرحبا', Lang.ar, '/tmp/b.wav');
    expect(sherpa.calls, [('Hello', Lang.en, '3')]);
    expect(system.calls, [('مرحبا', Lang.ar, 'ar-voice|ar')]);
  });

  test('uses system engine when the model is not installed', () async {
    sherpa.supported = {};
    expect(await router.engineFor(Lang.en), TtsEngineId.system);
    await router.synthesize('Hello', Lang.en, '/tmp/a.wav');
    expect(system.calls.single.$1, 'Hello');
  });

  test('engine crash falls back to system and disables the engine', () async {
    sherpa.fail = true;
    final notices = <AppException>[];
    router.notices.listen(notices.add);

    await router.synthesize('One', Lang.en, '/tmp/a.wav');
    await router.synthesize('Two', Lang.en, '/tmp/b.wav');
    await Future<void>.delayed(Duration.zero);

    expect(system.calls.map((c) => c.$1), ['One', 'Two']);
    expect(notices.single.kind, AppErrorKind.engineFailed);
    expect(await router.engineFor(Lang.en), TtsEngineId.system);

    router.resetFailures();
    expect(await router.engineFor(Lang.en), TtsEngineId.sherpa);
  });

  test('system engine errors are not swallowed', () async {
    system.fail = true;
    expect(
      () => router.synthesize('x', Lang.ar, '/tmp/c.wav'),
      throwsA(isA<AppException>()),
    );
  });

  test('fingerprint changes with voice settings', () {
    final before = router.fingerprint();
    settings = settings.copyWith(voices: {'en.sherpa': '11'});
    expect(router.fingerprint(), isNot(before));
  });
}
