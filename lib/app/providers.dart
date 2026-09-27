import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_paths.dart';
import '../data/db/app_database.dart';
import '../data/pdf/pdfrx_text_source.dart';
import '../data/repositories/drift_book_repository.dart';
import '../data/repositories/drift_settings_repository.dart';
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

/// All engines by id. M3 adds the sherpa-onnx engine here.
final ttsEnginesProvider = Provider<Map<TtsEngineId, TtsEngine>>(
  (ref) => {TtsEngineId.system: ref.watch(systemTtsProvider)},
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
