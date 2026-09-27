import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../db/app_database.dart';

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db);

  final AppDatabase _db;

  @override
  Future<AppSettings> load() async {
    final rows = await _db.select(_db.settings).get();
    return AppSettings.fromMap({for (final r in rows) r.key: r.value});
  }

  @override
  Future<void> save(AppSettings settings) => _db.transaction(() async {
    await _db.delete(_db.settings).go();
    await _db.batch(
      (b) => b.insertAll(_db.settings, [
        for (final e in settings.toMap().entries)
          SettingsCompanion.insert(key: e.key, value: e.value),
      ]),
    );
  });
}
