import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../core/errors.dart';
import 'model_catalog.dart';

enum ModelStatus {
  checking,
  notInstalled,
  downloading,
  verifying,
  extracting,
  installed,
  failed,
}

class ModelProgress {
  const ModelProgress(
    this.status, {
    this.received = 0,
    this.total = 0,
    this.error,
  });

  final ModelStatus status;
  final int received;
  final int total;
  final AppException? error;

  double? get fraction => total > 0 ? received / total : null;
  bool get busy =>
      status == ModelStatus.downloading ||
      status == ModelStatus.verifying ||
      status == ModelStatus.extracting;
}

/// Downloads, verifies (size + SHA-256), extracts and deletes voice models
/// in `<documents>/models`. Downloads resume from a `.part` file with HTTP
/// Range requests, so a dropped connection or app restart does not start
/// over.
class ModelManager {
  ModelManager({required this.modelsDir, required this.freeBytes, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 60),
              followRedirects: true,
              maxRedirects: 8,
            ),
          );

  final String modelsDir;

  /// Free bytes on the volume holding a path (null if unknown).
  final Future<int?> Function(String path) freeBytes;
  final Dio _dio;

  static const _marker = '.qari_installed';

  final _progress = StreamController<(String, ModelProgress)>.broadcast();
  final _installed = <String>{};
  final _cancels = <String, CancelToken>{};

  /// (model id, progress) events.
  Stream<(String, ModelProgress)> get progress => _progress.stream;

  String dirOf(VoiceModel m) => p.join(modelsDir, m.dirName);
  String fileOf(VoiceModel m, String rel) => p.join(dirOf(m), rel);
  String _partOf(VoiceModel m) => p.join(modelsDir, '${m.archive}.part');

  /// Synchronous, cached check used on the synthesis path.
  bool isInstalledSync(VoiceModel m) => _installed.contains(m.id);

  /// Checks marker and required files on disk and refreshes the cache.
  Future<bool> checkInstalled(VoiceModel m) async {
    final marker = File(p.join(dirOf(m), _marker));
    var ok =
        await marker.exists() &&
        (await marker.readAsString()).trim() == m.sha256;
    if (ok) {
      for (final f in m.requiredFiles) {
        final file = File(fileOf(m, f));
        if (!await file.exists() || await file.length() == 0) {
          ok = false;
          break;
        }
      }
    }
    ok ? _installed.add(m.id) : _installed.remove(m.id);
    return ok;
  }

  /// Bytes already downloaded for [m] (resumable).
  Future<int> partialBytes(VoiceModel m) async {
    final f = File(_partOf(m));
    return await f.exists() ? await f.length() : 0;
  }

  void cancel(VoiceModel m) => _cancels[m.id]?.cancel();

  Future<void> install(VoiceModel m) async {
    if (_cancels.containsKey(m.id)) return; // already running
    final cancel = _cancels[m.id] = CancelToken();
    try {
      await Directory(modelsDir).create(recursive: true);
      await _checkSpace(m);
      final archive = await _download(m, cancel);

      _emit(m, const ModelProgress(ModelStatus.verifying));
      final digest = await Isolate.run(
        () async =>
            (await sha256.bind(File(archive).openRead()).first).toString(),
      );
      if (digest != m.sha256) {
        await File(archive).delete();
        throw AppException(AppErrorKind.checksumMismatch, digest);
      }

      _emit(m, const ModelProgress(ModelStatus.extracting));
      final tmp = p.join(modelsDir, '.tmp_${m.id}');
      final dest = dirOf(m);
      await Isolate.run(() => _extract(archive, tmp));
      final extracted = Directory(p.join(tmp, m.dirName));
      if (!await extracted.exists()) {
        throw const AppException(AppErrorKind.checksumMismatch, 'layout');
      }
      if (await Directory(dest).exists()) {
        await Directory(dest).delete(recursive: true);
      }
      await extracted.rename(dest);
      await Directory(tmp).delete(recursive: true);
      await File(p.join(dest, _marker)).writeAsString(m.sha256);
      await File(archive).delete();

      if (!await checkInstalled(m)) {
        throw const AppException(AppErrorKind.checksumMismatch, 'files');
      }
      _emit(m, const ModelProgress(ModelStatus.installed));
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        _emit(
          m,
          ModelProgress(
            ModelStatus.notInstalled,
            received: await partialBytes(m),
            total: m.archiveBytes,
          ),
        );
        return;
      }
      _fail(m, AppException(AppErrorKind.downloadFailed, e.message));
    } on FileSystemException catch (e) {
      _fail(
        m,
        e.osError?.errorCode == 28
            ? AppException(AppErrorKind.lowStorage, e.message)
            : AppException(AppErrorKind.unknown, '$e'),
      );
    } on AppException catch (e) {
      _fail(m, e);
    } catch (e) {
      _fail(m, AppException(AppErrorKind.unknown, '$e'));
    } finally {
      _cancels.remove(m.id);
    }
  }

  Future<void> delete(VoiceModel m) async {
    cancel(m);
    for (final path in [dirOf(m), p.join(modelsDir, '.tmp_${m.id}')]) {
      final d = Directory(path);
      if (await d.exists()) await d.delete(recursive: true);
    }
    final part = File(_partOf(m));
    if (await part.exists()) await part.delete();
    _installed.remove(m.id);
    _emit(m, const ModelProgress(ModelStatus.notInstalled));
  }

  Future<void> _checkSpace(VoiceModel m) async {
    final free = await freeBytes(modelsDir);
    if (free == null) return; // unknown: let the write fail if it must
    final need = m.bytesNeededToInstall - await partialBytes(m);
    if (free < need) {
      throw AppException(AppErrorKind.lowStorage, 'need $need, free $free');
    }
  }

  /// Downloads to `<archive>.part`, resuming if possible; returns the path
  /// of the complete archive.
  Future<String> _download(VoiceModel m, CancelToken cancel) async {
    final part = File(_partOf(m));
    var have = await part.exists() ? await part.length() : 0;
    if (have > m.archiveBytes) {
      await part.delete();
      have = 0;
    }

    AppException? last;
    for (final url in m.urls) {
      for (var attempt = 0; attempt < 3; attempt++) {
        if (have == m.archiveBytes) return part.path;
        try {
          have = await _fetch(url, part, have, m, cancel);
          if (have == m.archiveBytes) return part.path;
          last = AppException(AppErrorKind.downloadFailed, 'short: $have');
        } on DioException catch (e) {
          if (CancelToken.isCancel(e)) rethrow;
          last = AppException(AppErrorKind.downloadFailed, e.message);
          have = await part.exists() ? await part.length() : 0;
          await Future<void>.delayed(Duration(seconds: 2 << attempt));
        } on IOException catch (e) {
          // Connection dropped mid-body: keep what we have and resume.
          if (cancel.isCancelled) rethrow;
          last = AppException(AppErrorKind.downloadFailed, '$e');
          have = await part.exists() ? await part.length() : 0;
          await Future<void>.delayed(Duration(seconds: 2 << attempt));
        }
      }
    }
    throw last ?? const AppException(AppErrorKind.downloadFailed);
  }

  Future<int> _fetch(
    String url,
    File part,
    int have,
    VoiceModel m,
    CancelToken cancel,
  ) async {
    final res = await _dio.get<ResponseBody>(
      url,
      cancelToken: cancel,
      options: Options(
        responseType: ResponseType.stream,
        headers: {if (have > 0) HttpHeaders.rangeHeader: 'bytes=$have-'},
        validateStatus: (s) => s == 200 || s == 206,
      ),
    );
    // Server ignored the range: start over.
    final append = res.statusCode == 206 && have > 0;
    if (!append) have = 0;
    final sink = part.openWrite(
      mode: append ? FileMode.append : FileMode.write,
    );
    var received = have;
    var lastEmit = DateTime.fromMillisecondsSinceEpoch(0);
    try {
      await for (final chunk in res.data!.stream) {
        sink.add(chunk);
        received += chunk.length;
        final now = DateTime.now();
        if (now.difference(lastEmit).inMilliseconds > 250) {
          lastEmit = now;
          _emit(
            m,
            ModelProgress(
              ModelStatus.downloading,
              received: received,
              total: m.archiveBytes,
            ),
          );
        }
      }
    } finally {
      await sink.flush();
      await sink.close();
    }
    _emit(
      m,
      ModelProgress(
        ModelStatus.downloading,
        received: received,
        total: m.archiveBytes,
      ),
    );
    return received;
  }

  /// Runs in a background isolate: .tar.bz2 -> .tar -> files.
  static void _extract(String archivePath, String outDir) {
    final out = Directory(outDir);
    if (out.existsSync()) out.deleteSync(recursive: true);
    out.createSync(recursive: true);
    final tarPath = p.join(outDir, '.archive.tar');

    final input = InputFileStream(archivePath);
    final tar = OutputFileStream(tarPath);
    try {
      BZip2Decoder().decodeStream(input, tar);
    } finally {
      input.closeSync();
      tar.closeSync();
    }

    final tarIn = InputFileStream(tarPath);
    try {
      extractArchiveToDiskSync(TarDecoder().decodeStream(tarIn), outDir);
    } finally {
      tarIn.closeSync();
      File(tarPath).deleteSync();
    }
  }

  void _emit(VoiceModel m, ModelProgress pr) {
    if (!_progress.isClosed) _progress.add((m.id, pr));
  }

  void _fail(VoiceModel m, AppException e) =>
      _emit(m, ModelProgress(ModelStatus.failed, error: e));

  Future<void> dispose() async {
    for (final c in _cancels.values) {
      c.cancel();
    }
    await _progress.close();
  }
}
