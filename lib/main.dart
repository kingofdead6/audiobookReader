import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'data/app_paths.dart';
import 'data/db/app_database.dart';
import 'data/repositories/drift_settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await pdfrxFlutterInitialize();

  final paths = await AppPaths.resolve();
  final db = AppDatabase();
  final settings = await DriftSettingsRepository(db).load();

  runApp(
    ProviderScope(
      overrides: [
        appPathsProvider.overrideWithValue(paths),
        databaseProvider.overrideWithValue(db),
        initialSettingsProvider.overrideWithValue(settings),
      ],
      child: const QariApp(),
    ),
  );
}
