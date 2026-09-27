import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_paths.dart';
import '../data/db/app_database.dart';
import '../data/models/model_catalog.dart';
import '../data/models/model_manager.dart';
import '../data/pdf/pdfrx_text_source.dart';
import '../data/repositories/drift_book_repository.dart';
import '../data/repositories/drift_settings_repository.dart';
import '../data/system_channel.dart';
import '../data/tts/sherpa_tts_engine.dart';
import '../data/tts/system_tts_engine.dart';
import '../domain/entities/app_settings.dart';
import '../domain/entities/book.dart';
import '../domain/entities/page_content.dart';
import '../domain/repositories/book_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/tts/tts_engine.dart';
import '../domain/usecases/import_book.dart';
import '../playback/reader_player.dart';
import '../playback/tts_router.dart';

// Overridden in main() once resolved asynchronously.
final appPathsProvider = Provider<AppPaths>(
  (ref) => throw UnimplementedError('appPathsProvider'),
);
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider'),
);
final initialSettingsProvider = Provider<AppSettings>(
  (ref) => const AppSettings(),
);

final bookRepositoryProvider = Provider<BookRepository>(
  (ref) => DriftBookRepository(ref.watch(databaseProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => DriftSettingsRepository(ref.watch(databaseProvider)),
);

final importBookProvider = Provider<ImportBook>((ref) {
  final paths = ref.watch(appPathsProvider);
  return ImportBook(
    books: ref.watch(bookRepositoryProvider),
    source: const PdfrxTextSource(),
    booksDir: paths.books,
    coversDir: paths.covers,
  );
});

final booksProvider = StreamProvider<List<Book>>(
  (ref) => ref.watch(bookRepositoryProvider).watchBooks(),
);

final bookProvider = StreamProvider.family<Book?, int>(
  (ref, id) => ref.watch(bookRepositoryProvider).watchBook(id),
);

final pageContentProvider = FutureProvider.autoDispose
    .family<PageContent, (int, int)>((ref, key) {
      final (bookId, pageIndex) = key;
      return ref.watch(bookRepositoryProvider).page(bookId, pageIndex);
    });

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(initialSettingsProvider);

  Future<void> update(AppSettings Function(AppSettings) change) async {
    state = change(state);
    await ref.read(settingsRepositoryProvider).save(state);
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

// ------------------------------------------------------------- playback

final systemTtsProvider = Provider<SystemTtsEngine>((ref) => SystemTtsEngine());

final sherpaTtsProvider = Provider<SherpaTtsEngine>((ref) {
  final engine = SherpaTtsEngine(models: ref.watch(modelManagerProvider));
  ref.onDispose(engine.dispose);
  return engine;
});

/// All engines by id.
final ttsEnginesProvider = Provider<Map<TtsEngineId, TtsEngine>>(
  (ref) => {
    TtsEngineId.system: ref.watch(systemTtsProvider),
    TtsEngineId.sherpa: ref.watch(sherpaTtsProvider),
  },
);

final ttsRouterProvider = Provider<TtsRouter>((ref) {
  final router = TtsRouter(
    engines: ref.watch(ttsEnginesProvider),
    settings: () => ref.read(settingsProvider),
  );
  ref.onDispose(router.dispose);
  return router;
});

/// The single app-wide player (also driven by the media notification).
final readerPlayerProvider = Provider<ReaderPlayer>((ref) {
  final player = ReaderPlayer(
    books: ref.watch(bookRepositoryProvider),
    router: ref.watch(ttsRouterProvider),
    cacheDir: ref.watch(appPathsProvider).ttsCache,
  );
  ref.listen(settingsProvider, (_, _) => player.onVoiceSettingsChanged());
  ref.onDispose(player.dispose);
  return player;
});

final readerStateProvider = StreamProvider<ReaderState>((ref) {
  final player = ref.watch(readerPlayerProvider);
  return player.states;
});

// ---------------------------------------------------------- voice models

final modelManagerProvider = Provider<ModelManager>((ref) {
  final m = ModelManager(
    modelsDir: ref.watch(appPathsProvider).models,
    freeBytes: const SystemChannel().freeBytes,
  );
  ref.onDispose(m.dispose);
  return m;
});

/// Live status of every catalog model, keyed by model id.
class ModelStates extends Notifier<Map<String, ModelProgress>> {
  @override
  Map<String, ModelProgress> build() {
    final manager = ref.watch(modelManagerProvider);
    final sub = manager.progress.listen((e) {
      final (id, progress) = e;
      state = {...state, id: progress};
      if (progress.status == ModelStatus.installed) _onInstalled(id);
    });
    ref.onDispose(sub.cancel);
    Future.microtask(refresh);
    return {
      for (final m in voiceModels)
        m.id: const ModelProgress(ModelStatus.checking),
    };
  }

  Future<void> refresh() async {
    final manager = ref.read(modelManagerProvider);
    final next = <String, ModelProgress>{};
    for (final m in voiceModels) {
      final current = state[m.id];
      if (current != null && current.busy) {
        next[m.id] = current;
        continue;
      }
      if (await manager.checkInstalled(m)) {
        next[m.id] = const ModelProgress(ModelStatus.installed);
      } else {
        next[m.id] = ModelProgress(
          ModelStatus.notInstalled,
          received: await manager.partialBytes(m),
          total: m.archiveBytes,
        );
      }
    }
    state = next;
  }

  Future<void> install(VoiceModel m) async {
    state = {
      ...state,
      m.id: ModelProgress(
        ModelStatus.downloading,
        received: await ref.read(modelManagerProvider).partialBytes(m),
        total: m.archiveBytes,
      ),
    };
    await ref.read(modelManagerProvider).install(m);
  }

  void cancel(VoiceModel m) => ref.read(modelManagerProvider).cancel(m);

  Future<void> delete(VoiceModel m) async {
    await ref.read(sherpaTtsProvider).unload(m.id);
    await ref.read(modelManagerProvider).delete(m);
    // Fall back to the system voice if no model is left for the language.
    if (!await ref.read(sherpaTtsProvider).supports(m.lang)) {
      await ref
          .read(settingsProvider.notifier)
          .update(
            (s) =>
                s.copyWith(engines: {...s.engines, m.lang: TtsEngineId.system}),
          );
    }
  }

  /// A freshly installed model becomes the voice for its language.
  Future<void> _onInstalled(String id) async {
    final m = modelById(id);
    if (m == null) return;
    ref.read(ttsRouterProvider).resetFailures();
    await ref.read(settingsProvider.notifier).update((s) {
      final voices = Map.of(s.voices)
        ..[AppSettings.voiceKey(m.lang, TtsEngineId.sherpa)] =
            '${m.id}:${m.defaultSpeaker}';
      return s.copyWith(
        engines: {...s.engines, m.lang: TtsEngineId.sherpa},
        voices: voices,
      );
    });
  }
}

final modelStatesProvider =
    NotifierProvider<ModelStates, Map<String, ModelProgress>>(ModelStates.new);
