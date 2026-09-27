import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;

import '../../app/providers.dart';
import '../../data/models/model_catalog.dart';
import '../../data/models/model_manager.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/lang.dart';
import '../../domain/tts/tts_engine.dart';
import '../../l10n/gen/app_localizations.dart';
import '../downloads/downloads_screen.dart';
import '../widgets/error_text.dart';

/// Voices offered by [engine] for [lang].
final voicesProvider = FutureProvider.autoDispose
    .family<List<TtsVoice>, (TtsEngineId, Lang)>((ref, key) async {
      final (engineId, lang) = key;
      final engine = ref.watch(ttsEnginesProvider)[engineId];
      if (engine == null) return const [];
      return engine.voices(lang);
    });

/// Engine + voice picker and a "test" button for one language.
class VoiceSection extends ConsumerStatefulWidget {
  const VoiceSection({super.key, required this.lang});

  final Lang lang;

  @override
  ConsumerState<VoiceSection> createState() => _VoiceSectionState();
}

class _VoiceSectionState extends ConsumerState<VoiceSection> {
  bool _testing = false;

  String _langName(AppLocalizations l) =>
      widget.lang == Lang.ar ? l.arabic : l.english;

  Future<void> _test() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _testing = true);
    final player = AudioPlayer();
    try {
      final out = p.join(
        ref.read(appPathsProvider).ttsCache,
        'test_${DateTime.now().millisecondsSinceEpoch}.wav',
      );
      final text = widget.lang == Lang.ar ? l.testSentenceAr : l.testSentenceEn;
      await ref.read(ttsRouterProvider).synthesize(text, widget.lang, out);
      await player.setFilePath(out);
      await player.play();
      await player.processingStateStream
          .firstWhere((s) => s == ProcessingState.completed)
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(l, e))));
    } finally {
      await player.dispose();
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final engine = settings.engineFor(widget.lang);
    final voices = ref.watch(voicesProvider((engine, widget.lang)));
    final selected = settings.voiceFor(widget.lang, engine);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.voiceFor(_langName(l)),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _EngineSelector(lang: widget.lang, selected: engine),
            const SizedBox(height: 8),
            voices.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(errorMessage(l, e)),
              data: (list) => list.isEmpty
                  ? Text(l.noVoicesFound)
                  : DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: list.any((v) => v.id == selected)
                          ? selected
                          : '',
                      items: [
                        DropdownMenuItem(
                          value: '',
                          child: Text(l.systemVoiceDefault),
                        ),
                        for (final v in list)
                          DropdownMenuItem(
                            value: v.id,
                            child: Text(
                              v.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (id) =>
                          ref.read(settingsProvider.notifier).update((s) {
                            final key = AppSettings.voiceKey(
                              widget.lang,
                              engine,
                            );
                            final voices = Map.of(s.voices);
                            if (id == null || id.isEmpty) {
                              voices.remove(key);
                            } else {
                              voices[key] = id;
                            }
                            return s.copyWith(voices: voices);
                          }),
                    ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton.tonalIcon(
                onPressed: _testing ? null : _test,
                icon: _testing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.volume_up_outlined),
                label: Text(l.testVoice),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EngineSelector extends ConsumerWidget {
  const _EngineSelector({required this.lang, required this.selected});
  final Lang lang;
  final TtsEngineId selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final states = ref.watch(modelStatesProvider);
    final hasModel = voiceModels.any(
      (m) => m.lang == lang && states[m.id]?.status == ModelStatus.installed,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<TtsEngineId>(
          segments: [
            ButtonSegment(
              value: TtsEngineId.system,
              label: Text(l.engineSystem),
              icon: const Icon(Icons.phone_android),
            ),
            ButtonSegment(
              value: TtsEngineId.sherpa,
              label: Text(l.engineQari),
              icon: const Icon(Icons.graphic_eq),
              enabled: hasModel,
            ),
          ],
          selected: {hasModel ? selected : TtsEngineId.system},
          onSelectionChanged: (v) => ref
              .read(settingsProvider.notifier)
              .update(
                (s) => s.copyWith(engines: {...s.engines, lang: v.first}),
              ),
        ),
        if (!hasModel)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DownloadsScreen(),
                ),
              ),
              icon: const Icon(Icons.download, size: 18),
              label: Text(l.downloadVoiceHint),
            ),
          ),
      ],
    );
  }
}
