import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../playback/reader_player.dart';

/// Shows the current speed; opens a sheet with a 0.5×–2× slider.
class SpeedButton extends ConsumerWidget {
  const SpeedButton({super.key, required this.state});
  final ReaderState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return SizedBox(
      width: 64,
      child: TextButton(
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (_) => const _SpeedSheet(),
        ),
        child: Tooltip(
          message: l.speed,
          child: Text(
            '${_fmt(state.speed)}×',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

String _fmt(double v) => v == v.roundToDouble()
    ? v.toStringAsFixed(1)
    : '${(v * 100).round() / 100}';

class _SpeedSheet extends ConsumerWidget {
  const _SpeedSheet();

  static const presets = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  Future<void> _set(WidgetRef ref, double v) async {
    final speed = (v * 20).round() / 20; // 0.05 steps
    await ref.read(readerPlayerProvider).setSpeed(speed);
    await ref
        .read(settingsProvider.notifier)
        .update((s) => s.copyWith(speed: speed));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final speed = ref.watch(settingsProvider).speed;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${l.speed}: ${_fmt(speed)}×',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: speed,
              min: 0.5,
              max: 2.0,
              divisions: 30,
              label: '${_fmt(speed)}×',
              onChanged: (v) => unawaited(_set(ref, v)),
            ),
            Wrap(
              spacing: 8,
              children: [
                for (final p in presets)
                  ChoiceChip(
                    label: Text('${_fmt(p)}×'),
                    selected: (speed - p).abs() < 0.01,
                    onSelected: (_) => unawaited(_set(ref, p)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Moon icon; shows the remaining time while a timer is active.
class SleepButton extends ConsumerStatefulWidget {
  const SleepButton({super.key, required this.state});
  final ReaderState state;

  @override
  ConsumerState<SleepButton> createState() => _SleepButtonState();
}

class _SleepButtonState extends ConsumerState<SleepButton> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && widget.state.sleepAt != null) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = widget.state;
    final active = s.sleepAt != null || s.sleepAtPageEnd;
    String? label;
    if (s.sleepAt != null) {
      final left = s.sleepAt!.difference(DateTime.now());
      final m = left.inMinutes;
      final sec = left.inSeconds % 60;
      label = '$m:${sec.toString().padLeft(2, '0')}';
    } else if (s.sleepAtPageEnd) {
      label = '¶';
    }

    return SizedBox(
      width: 64,
      child: IconButton(
        tooltip: label == null ? l.sleepTimer : l.sleepRemaining(label),
        isSelected: active,
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (_) => const _SleepSheet(),
        ),
        icon: label == null
            ? const Icon(Icons.bedtime_outlined)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bedtime, size: 20),
                  Text(label, style: const TextStyle(fontSize: 11)),
                ],
              ),
      ),
    );
  }
}

class _SleepSheet extends ConsumerWidget {
  const _SleepSheet();

  static const minutes = [5, 15, 30, 45, 60, 90];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final player = ref.read(readerPlayerProvider);
    void done() => Navigator.pop(context);

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              l.sleepTimer,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.timer_off_outlined),
            title: Text(l.sleepOff),
            onTap: () {
              player.setSleepTimer();
              done();
            },
          ),
          for (final m in minutes)
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: Text(l.minutesN(m)),
              onTap: () {
                player.setSleepTimer(duration: Duration(minutes: m));
                done();
              },
            ),
          ListTile(
            leading: const Icon(Icons.last_page),
            title: Text(l.endOfPage),
            onTap: () {
              player.setSleepTimer(atPageEnd: true);
              done();
            },
          ),
        ],
      ),
    );
  }
}
