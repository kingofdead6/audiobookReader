import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_paths.dart';
import '../data/db/app_database.dart';
import '../data/pdf/pdfrx_text_source.dart';
import '../data/repositories/drift_book_repository.dart';
import '../data/repositories/drift_settings_repository.dart';
import '../domain/entities/app_settings.dart';
import '../domain/entities/book.dart';
import '../domain/entities/page_content.dart';
import '../domain/repositories/book_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/usecases/import_book.dart';

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
