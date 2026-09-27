import 'package:flutter/material.dart';

const _seed = Color(0xFF1F9E8F);

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: brightness == Brightness.dark
        ? const Color(0xFF101413)
        : scheme.surface,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

/// Highlight colours for language tagging in the text views.
extension ReaderColors on ColorScheme {
  Color get englishTint => tertiaryContainer.withValues(alpha: 0.35);
  Color get arabicTint => secondaryContainer.withValues(alpha: 0.35);
  Color get currentSentence => primaryContainer;
}
