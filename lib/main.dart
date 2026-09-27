import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'data/app_paths.dart';
import 'data/db/app_database.dart';
import 'data/repositories/drift_settings_repository.dart';
import 'playback/audio_focus.dart';
import 'playback/qari_audio_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await pdfrxFlutterInitialize();

  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.speech());

  final paths = await AppPaths.resolve();
  // Synthesized audio from a previous run is never reused.
  await for (final f in Directory(paths.ttsCache).list()) {
    await f.delete(recursive: true).catchError((_) => f);
  }
  final db = AppDatabase();
  final settings = await DriftSettingsRepository(db).load();

  final container = ProviderContainer(
    overrides: [
      appPathsProvider.overrideWithValue(paths),
      databaseProvider.overrideWithValue(db),
      initialSettingsProvider.overrideWithValue(settings),
    ],
  );

  // Starts checking which voice models are installed.
  container.read(modelStatesProvider);

  final player = container.read(readerPlayerProvider);
  await player.setSpeed(settings.speed);
  bindAudioFocus(session, player);

  // Notification / lock-screen controls. Playback still works in the
  // foreground if the media service cannot start.
  try {
    await AudioService.init(
      builder: () => QariAudioHandler(player),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.qari.qari.playback',
        androidNotificationChannelName: 'Qari playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'drawable/ic_stat_qari',
      ),
    );
  } catch (e) {
    debugPrint('AudioService.init failed: $e');
  }

  // Restore the last book so "continue listening" is one tap away.
  final books = await container.read(bookRepositoryProvider).watchBooks().first;
  final recent = books.where((b) => b.lastOpenedAt != null).firstOrNull;
  if (recent != null) unawaited(player.open(recent.id, prefetch: false));

  runApp(
    UncontrolledProviderScope(container: container, child: const QariApp()),
  );
}
