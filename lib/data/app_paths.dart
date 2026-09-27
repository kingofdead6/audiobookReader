import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Directory layout inside the app sandbox.
///
/// documents/books   imported PDFs (copied, so the original can be deleted)
/// documents/covers  first-page thumbnails
/// documents/models  downloaded voice models (survive app updates; must be
///                   re-downloaded on a new phone)
/// cache/tts         short-lived synthesized sentence audio
class AppPaths {
  AppPaths._(this.documents, this.cache);

  final String documents;
  final String cache;

  static Future<AppPaths> resolve() async {
    final docs = await getApplicationDocumentsDirectory();
    final cache = await getApplicationCacheDirectory();
    final paths = AppPaths._(docs.path, cache.path);
    for (final d in [paths.books, paths.covers, paths.models, paths.ttsCache]) {
      await Directory(d).create(recursive: true);
    }
    return paths;
  }

  String get books => p.join(documents, 'books');
  String get covers => p.join(documents, 'covers');
  String get models => p.join(documents, 'models');
  String get ttsCache => p.join(cache, 'tts');
}
