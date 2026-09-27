import '../../domain/entities/lang.dart';

enum ModelKind { kokoro, piper }

class ModelSpeaker {
  const ModelSpeaker(this.id, this.name);

  /// sherpa-onnx speaker id (`sid`).
  final int id;
  final String name;
}

/// A downloadable sherpa-onnx voice model.
///
/// Archives come from the official sherpa-onnx GitHub release `tts-models`
/// (https://github.com/k2-fsa/sherpa-onnx/releases/tag/tts-models). The
/// SHA-256 and sizes were measured from those release assets and are
/// checked after every download.
class VoiceModel {
  const VoiceModel({
    required this.id,
    required this.lang,
    required this.kind,
    required this.title,
    required this.archive,
    required this.sha256,
    required this.archiveBytes,
    required this.installedBytes,
    required this.dirName,
    required this.modelFile,
    required this.requiredFiles,
    required this.speakers,
    required this.defaultSpeaker,
    required this.threads,
    this.lexicons = const [],
    this.license = '',
    this.customUrls,
  });

  final String id;
  final Lang lang;
  final ModelKind kind;
  final String title;
  final String archive;
  final String sha256;
  final int archiveBytes;

  /// Size after extraction (for the free-space check).
  final int installedBytes;

  /// Top-level directory inside the archive.
  final String dirName;
  final String modelFile;

  /// Files that must exist (relative to [dirName]) for the model to count
  /// as installed.
  final List<String> requiredFiles;
  final List<ModelSpeaker> speakers;
  final int defaultSpeaker;

  /// ONNX Runtime threads; Kokoro is heavier and benefits from more.
  final int threads;
  final List<String> lexicons;
  final String license;

  /// Replaces the GitHub release URL (tests, future mirrors).
  final List<String>? customUrls;

  static const _base =
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models';

  List<String> get urls => customUrls ?? ['$_base/$archive'];

  /// Free space needed while installing: the archive, the unpacked tar and
  /// the extracted files, plus headroom.
  int get bytesNeededToInstall =>
      archiveBytes + installedBytes * 2 + 50 * 1024 * 1024;
}

/// Kokoro v1.0 English speakers (ids 0–27 of the 54-voice table; the
/// order comes from the model's `speaker_names` metadata).
const _kokoroEnglish = [
  ModelSpeaker(0, 'Alloy · US ♀'),
  ModelSpeaker(1, 'Aoede · US ♀'),
  ModelSpeaker(2, 'Bella · US ♀'),
  ModelSpeaker(3, 'Heart · US ♀'),
  ModelSpeaker(4, 'Jessica · US ♀'),
  ModelSpeaker(5, 'Kore · US ♀'),
  ModelSpeaker(6, 'Nicole · US ♀'),
  ModelSpeaker(7, 'Nova · US ♀'),
  ModelSpeaker(8, 'River · US ♀'),
  ModelSpeaker(9, 'Sarah · US ♀'),
  ModelSpeaker(10, 'Sky · US ♀'),
  ModelSpeaker(11, 'Adam · US ♂'),
  ModelSpeaker(12, 'Echo · US ♂'),
  ModelSpeaker(13, 'Eric · US ♂'),
  ModelSpeaker(14, 'Fenrir · US ♂'),
  ModelSpeaker(15, 'Liam · US ♂'),
  ModelSpeaker(16, 'Michael · US ♂'),
  ModelSpeaker(17, 'Onyx · US ♂'),
  ModelSpeaker(18, 'Puck · US ♂'),
  ModelSpeaker(19, 'Santa · US ♂'),
  ModelSpeaker(20, 'Alice · UK ♀'),
  ModelSpeaker(21, 'Emma · UK ♀'),
  ModelSpeaker(22, 'Isabella · UK ♀'),
  ModelSpeaker(23, 'Lily · UK ♀'),
  ModelSpeaker(24, 'Daniel · UK ♂'),
  ModelSpeaker(25, 'Fable · UK ♂'),
  ModelSpeaker(26, 'George · UK ♂'),
  ModelSpeaker(27, 'Lewis · UK ♂'),
];

const voiceModels = <VoiceModel>[
  VoiceModel(
    id: 'kokoro-en-v1',
    lang: Lang.en,
    kind: ModelKind.kokoro,
    title: 'Kokoro v1.0 (English, natural)',
    archive: 'kokoro-int8-multi-lang-v1_0.tar.bz2',
    sha256: '4c3052abaa60943a341f193888cf6abd68787dae6ab8ae5c925a706caa247e4e',
    archiveBytes: 132303094,
    installedBytes: 189882497,
    dirName: 'kokoro-int8-multi-lang-v1_0',
    modelFile: 'model.int8.onnx',
    requiredFiles: [
      'model.int8.onnx',
      'voices.bin',
      'tokens.txt',
      'lexicon-us-en.txt',
      'lexicon-zh.txt',
      'espeak-ng-data/phontab',
    ],
    lexicons: ['lexicon-us-en.txt', 'lexicon-zh.txt'],
    speakers: _kokoroEnglish,
    defaultSpeaker: 3,
    threads: 4,
    license: 'Apache-2.0',
  ),
  VoiceModel(
    id: 'piper-ar-kareem',
    lang: Lang.ar,
    kind: ModelKind.piper,
    title: 'Piper Kareem (Arabic, ar_JO)',
    archive: 'vits-piper-ar_JO-kareem-medium.tar.bz2',
    sha256: '9ebbcea30e0fbd588f7b2cb45ee897d6aeb1bf5791cbc037a7b5a3f641e3dbce',
    archiveBytes: 67177830,
    installedBytes: 81147102,
    dirName: 'vits-piper-ar_JO-kareem-medium',
    modelFile: 'ar_JO-kareem-medium.onnx',
    requiredFiles: [
      'ar_JO-kareem-medium.onnx',
      'tokens.txt',
      'espeak-ng-data/phontab',
    ],
    speakers: [ModelSpeaker(0, 'Kareem ♂')],
    defaultSpeaker: 0,
    threads: 2,
    license: 'see MODEL_CARD',
  ),
  VoiceModel(
    id: 'piper-en-lessac',
    lang: Lang.en,
    kind: ModelKind.piper,
    title: 'Piper Lessac (English, fast — for slower phones)',
    archive: 'vits-piper-en_US-lessac-medium.tar.bz2',
    sha256: '9e3febfacf0abf4270172d2958bcec246032b7e88efc2720840cc80c93de334e',
    archiveBytes: 67230653,
    installedBytes: 81147006,
    dirName: 'vits-piper-en_US-lessac-medium',
    modelFile: 'en_US-lessac-medium.onnx',
    requiredFiles: [
      'en_US-lessac-medium.onnx',
      'tokens.txt',
      'espeak-ng-data/phontab',
    ],
    speakers: [ModelSpeaker(0, 'Lessac ♀')],
    defaultSpeaker: 0,
    threads: 2,
    license: 'see MODEL_CARD',
  ),
];

VoiceModel? modelById(String id) =>
    voiceModels.where((m) => m.id == id).firstOrNull;
