import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/entities/app_settings.dart';
import '../../l10n/gen/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final ctrl = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        children: [
          _Header(l.appLanguage),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: '', label: Text(l.followSystem)),
                const ButtonSegment(value: 'en', label: Text('English')),
                const ButtonSegment(value: 'ar', label: Text('العربية')),
              ],
              selected: {s.localeCode ?? ''},
              onSelectionChanged: (v) => ctrl.update(
                (x) => x.copyWith(
                  localeCode: () => v.first.isEmpty ? null : v.first,
                ),
              ),
            ),
          ),
          _Header(l.theme),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<AppThemeMode>(
              segments: [
                ButtonSegment(
                  value: AppThemeMode.dark,
                  label: Text(l.themeDark),
                ),
                ButtonSegment(
                  value: AppThemeMode.light,
                  label: Text(l.themeLight),
                ),
                ButtonSegment(
                  value: AppThemeMode.system,
                  label: Text(l.themeSystem),
                ),
              ],
              selected: {s.themeMode},
              onSelectionChanged: (v) =>
                  ctrl.update((x) => x.copyWith(themeMode: v.first)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleSmall
          ?.copyWith(color: Theme.of(context).colorScheme.primary),
    ),
  );
}
