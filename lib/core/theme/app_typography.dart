import 'package:flutter/material.dart';

/// Typography tokens. Mirrors MASTER.md §3.
///
/// Fonts are bundled in `assets/fonts/` and declared in pubspec.yaml so the
/// app is fully offline-capable and never flickers while a remote font
/// downloads.
///
/// Colors flow from the active theme's [TextTheme] (wired per-palette in
/// `AppTheme._build`). Callers override via `.copyWith(color: ...)` only
/// when they need a specific non-default color.
class AppTypography {
  AppTypography._();

  static const _playfair = 'PlayfairDisplay';
  static const _inter = 'Inter';
  static const _outfit = 'Outfit';

  static TextStyle _ts({
    required String family,
    required double size,
    required double height,
    required FontWeight weight,
    double letterSpacing = 0,
    List<FontFeature>? features,
  }) =>
      TextStyle(
        fontFamily: family,
        fontSize: size,
        height: height / size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        fontFeatures: features,
      );

  // Display / Heading — Playfair. Lightest bundled weight is 400; feels
  // elegant against both palettes without faking thinness via synthesis.
  static TextStyle get displayLg => _ts(
        family: _playfair,
        size: 40,
        height: 48,
        weight: FontWeight.w400,
      );
  static TextStyle get displayMd => _ts(
        family: _playfair,
        size: 32,
        height: 40,
        weight: FontWeight.w400,
      );
  static TextStyle get headline => _ts(
        family: _playfair,
        size: 24,
        height: 32,
        weight: FontWeight.w500,
      );

  // UI — Inter
  static TextStyle get title => _ts(
        family: _inter,
        size: 18,
        height: 26,
        weight: FontWeight.w600,
      );
  static TextStyle get bodyLg => _ts(
        family: _inter,
        size: 16,
        height: 24,
        weight: FontWeight.w400,
      );
  static TextStyle get bodyMd => _ts(
        family: _inter,
        size: 14,
        height: 22,
        weight: FontWeight.w400,
      );
  static TextStyle get label => _ts(
        family: _inter,
        size: 12,
        height: 16,
        weight: FontWeight.w500,
        letterSpacing: 0.3,
      );

  // Numeric — Outfit (tabular figures for the timer)
  static TextStyle get timer => _ts(
        family: _outfit,
        size: 64,
        height: 64,
        weight: FontWeight.w300,
        features: const [FontFeature.tabularFigures()],
      );
  static TextStyle get duration => _ts(
        family: _outfit,
        size: 18,
        height: 24,
        weight: FontWeight.w400,
        features: const [FontFeature.tabularFigures()],
      );
}
