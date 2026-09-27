import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:qari/core/errors.dart';
import 'package:qari/data/models/model_catalog.dart';
import 'package:qari/data/models/model_manager.dart';
import 'package:qari/domain/entities/lang.dart';

/// Serves [bytes] with HTTP Range support; can cut a response short.
class TestServer {
  TestServer(this.bytes);
  final List<int> bytes;
  late HttpServer server;
  int? cutAfter;
  final requests = <String?>[];

  Future<void> start() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      final range = req.headers.value(HttpHeaders.rangeHeader);
      requests.add(range);
      var start = 0;
      if (range != null) {
        start = int.parse(RegExp(r'bytes=(\d+)-').firstMatch(range)!.group(1)!);
        req.response.statusCode = 206;
      }
      var body = bytes.sublist(start);
      final cut = cutAfter;
      if (cut != null) {
        cutAfter = null;
        req.response.contentLength = body.length;
        final socket = await req.response.detachSocket(writeHeaders: true);
        socket.add(body.sublist(0, cut));
        await socket.flush();
        socket.destroy();
        return;
      }
      req.response.contentLength = body.length;
      req.response.add(body);
      await req.response.close();
    });
  }

  String get url => 'http://127.0.0.1:${server.port}/model.tar.bz2';
}

List<int> buildArchive() {
  final a = Archive()
    ..add(ArchiveFile.bytes('fake-model/model.onnx', List.filled(5000, 7)))
    ..add(ArchiveFile.bytes('fake-model/tokens.txt', 'a 1\nb 2\n'.codeUnits))
    ..add(
      ArchiveFile.bytes(
        'fake-model/espeak-ng-data/phontab',
        List.filled(100, 1),
      ),
    );
  return BZip2Encoder().encodeBytes(TarEncoder().encodeBytes(a));
}

VoiceModel fakeModel(String url, List<int> bytes, {String? sha}) => VoiceModel(
  id: 'fake',
  lang: Lang.en,
  kind: ModelKind.piper,
  title: 'Fake',
  archive: 'fake.tar.bz2',
  sha256: sha ?? sha256.convert(bytes).toString(),
  archiveBytes: bytes.length,
  installedBytes: 6000,
  dirName: 'fake-model',
  modelFile: 'model.onnx',
  requiredFiles: const ['model.onnx', 'tokens.txt', 'espeak-ng-data/phontab'],
  speakers: const [ModelSpeaker(0, 'x')],
  defaultSpeaker: 0,
  threads: 1,
  customUrls: [url],
);

void main() {
  late Directory tmp;
  late TestServer server;
  late List<int> bytes;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('qari_models');
    bytes = buildArchive();
    server = TestServer(bytes);
    await server.start();
  });

  tearDown(() async {
    await server.server.close(force: true);
    await tmp.delete(recursive: true);
  });

  ModelManager manager({int? free}) =>
      ModelManager(modelsDir: tmp.path, freeBytes: (_) async => free);

  test('downloads, verifies, extracts and marks installed', () async {
    final m = fakeModel(server.url, bytes);
    final mm = manager();
    final events = <ModelStatus>[];
    mm.progress.listen((e) => events.add(e.$2.status));

    await mm.install(m);

    expect(await mm.checkInstalled(m), isTrue);
    expect(mm.isInstalledSync(m), isTrue);
    expect(File(mm.fileOf(m, 'tokens.txt')).readAsStringSync(), 'a 1\nb 2\n');
    expect(File(p.join(tmp.path, 'fake.tar.bz2.part')).existsSync(), isFalse);
    expect(
      events,
      containsAllInOrder([
        ModelStatus.downloading,
        ModelStatus.verifying,
        ModelStatus.extracting,
        ModelStatus.installed,
      ]),
    );
  });

  test('resumes an interrupted download with a Range request', () async {
    final m = fakeModel(server.url, bytes);
    server.cutAfter = bytes.length ~/ 2;
    await manager().install(m);

    expect(server.requests.first, isNull);
    expect(server.requests.skip(1).first, startsWith('bytes='));
    expect(await manager().checkInstalled(m), isTrue);
  });

  test('checksum mismatch fails and discards the archive', () async {
    final m = fakeModel(server.url, bytes, sha: '0' * 64);
    final mm = manager();
    final errors = <AppException>[];
    mm.progress.listen((e) {
      if (e.$2.error != null) errors.add(e.$2.error!);
    });

    await mm.install(m);
    await Future<void>.delayed(Duration.zero);

    expect(errors.single.kind, AppErrorKind.checksumMismatch);
    expect(await mm.checkInstalled(m), isFalse);
    expect(await mm.partialBytes(m), 0);
  });

  test('refuses to start without enough free space', () async {
    final m = fakeModel(server.url, bytes);
    final mm = manager(free: 1000);
    final errors = <AppException>[];
    mm.progress.listen((e) {
      if (e.$2.error != null) errors.add(e.$2.error!);
    });

    await mm.install(m);
    await Future<void>.delayed(Duration.zero);

    expect(errors.single.kind, AppErrorKind.lowStorage);
    expect(server.requests, isEmpty);
  });

  test('delete removes files and installed state', () async {
    final m = fakeModel(server.url, bytes);
    final mm = manager();
    await mm.install(m);
    await mm.delete(m);
    expect(await mm.checkInstalled(m), isFalse);
    expect(Directory(mm.dirOf(m)).existsSync(), isFalse);
  });

  test('catalog entries are well-formed', () {
    for (final m in voiceModels) {
      expect(m.sha256, matches(RegExp(r'^[0-9a-f]{64}$')), reason: m.id);
      expect(m.urls.single, startsWith('https://github.com/k2-fsa/'));
      expect(m.requiredFiles, contains(m.modelFile));
      expect(m.speakers.map((s) => s.id), contains(m.defaultSpeaker));
    }
    expect(voiceModels.where((m) => m.lang == Lang.ar), isNotEmpty);
  });
}
