import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Dark (night sky) and light (dawn sky) themes both derive from the same
/// Material 3 scheme — only the palette differs. Brand/semantic/glow colors
/// come from [AppColors] and read identically in both modes.
class AppTheme {
  AppTheme._();

  static ThemeData dark() => _build(AppPalette.night, Brightness.dark);
  static ThemeData light() => _build(AppPalette.dawn, Brightness.light);

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final scheme = brightness == Brightness.dark
        ? ColorScheme.dark(
            primary: AppColors.brandViolet,
            onPrimary: p.textPrimary,
            secondary: AppColors.brandGold,
            onSecondary: p.textOnBrand,
            surface: p.bgMid,
            onSurface: p.textPrimary,
            error: AppColors.error,
            onError: p.textOnBrand,
          )
        : ColorScheme.light(
            primary: AppColors.brandViolet,
            onPrimary: p.textOnBrand,
            secondary: AppColors.brandGold,
            onSecondary: p.textPrimary,
            surface: p.bgMid,
            onSurface: p.textPrimary,
            error: AppColors.error,
            onError: p.textOnBrand,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.bgDeep,
      splashFactory: InkSparkle.splashFactory,
      textTheme: _textTheme(p),
      extensions: [p],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: p.textPrimary,
      ),
      iconTheme: IconThemeData(color: p.textPrimary, size: 24),
      dividerTheme: DividerThemeData(
        color: p.surfaceBorder,
        thickness: 1,
        space: AppSpacing.lg,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.bgMid,
        contentTextStyle: AppTypography.bodyMd.copyWith(color: p.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdR),
      ),
    );
  }

  static TextTheme _textTheme(AppPalette p) => TextTheme(
        displayLarge: AppTypography.displayLg.copyWith(color: p.textPrimary),
        displayMedium:
            AppTypography.displayMd.copyWith(color: p.textPrimary),
        headlineLarge:
            AppTypography.headline.copyWith(color: p.textPrimary),
        headlineMedium:
            AppTypography.headline.copyWith(color: p.textPrimary),
        titleLarge: AppTypography.title.copyWith(color: p.textPrimary),
        titleMedium: AppTypography.title.copyWith(color: p.textPrimary),
        bodyLarge: AppTypography.bodyLg.copyWith(color: p.textPrimary),
        bodyMedium: AppTypography.bodyMd.copyWith(color: p.textSecondary),
        labelLarge: AppTypography.label.copyWith(color: p.textPrimary),
        labelMedium: AppTypography.label.copyWith(color: p.textPrimary),
      );
}
