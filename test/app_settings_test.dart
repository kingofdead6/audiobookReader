import 'package:flutter_test/flutter_test.dart';
import 'package:qari/domain/entities/app_settings.dart';
import 'package:qari/domain/entities/lang.dart';

void main() {
  test('settings round-trip through the key/value map', () {
    const s = AppSettings(
      themeMode: AppThemeMode.light,
      localeCode: 'ar',
      engines: {Lang.en: TtsEngineId.sherpa, Lang.ar: TtsEngineId.system},
      voices: {'en.sherpa': '3', 'ar.system': 'x|ar'},
      speed: 1.5,
    );
    final r = AppSettings.fromMap(s.toMap());
    expect(r.themeMode, AppThemeMode.light);
    expect(r.localeCode, 'ar');
    expect(r.engineFor(Lang.en), TtsEngineId.sherpa);
    expect(r.voiceFor(Lang.en, TtsEngineId.sherpa), '3');
    expect(r.voiceFor(Lang.ar, TtsEngineId.system), 'x|ar');
    expect(r.speed, 1.5);
  });

  test('defaults: dark theme, system engines, normal speed', () {
    final r = AppSettings.fromMap(const {});
    expect(r.themeMode, AppThemeMode.dark);
    expect(r.localeCode, isNull);
    expect(r.engineFor(Lang.ar), TtsEngineId.system);
    expect(r.speed, 1.0);
  });
}
