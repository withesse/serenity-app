import 'package:flutter/material.dart';

/// Theme-swappable color tokens.
///
/// Tokens that *must* swap between dark (night sky) and light (dawn sky) live
/// here. Brand constants, semantic colors, and glow values that read the same
/// against any backdrop stay on `AppColors` as compile-time `const`.
///
/// Access via `context.palette.bgDeep`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.bgDeep,
    required this.bgMid,
    required this.bgTop,
    required this.surfaceGlass,
    required this.surfaceGlassElevated,
    required this.surfaceBorder,
    required this.surfaceBorderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnBrand,
    required this.skyGradient,
    required this.isDark,
  });

  final Color bgDeep;
  final Color bgMid;
  final Color bgTop;

  final Color surfaceGlass;
  final Color surfaceGlassElevated;
  final Color surfaceBorder;
  final Color surfaceBorderStrong;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textOnBrand;

  /// Three-stop vertical gradient used by [AuroraBackground].
  final List<Color> skyGradient;

  /// True when the active theme is dark-mode. Aurora/star overlays key off
  /// this instead of `Theme.of(context).brightness` so a single palette
  /// defines "this is the dark visual language" or "this is the dawn one".
  final bool isDark;

  // -- Night sky (dark) --
  static const night = AppPalette(
    bgDeep: Color(0xFF0B1426),
    bgMid: Color(0xFF1A1B3A),
    bgTop: Color(0xFF2D1B4E),
    surfaceGlass: Color(0x0FFFFFFF), // white 6%
    surfaceGlassElevated: Color(0x1AFFFFFF), // white 10%
    surfaceBorder: Color(0x1FFFFFFF), // white 12%
    surfaceBorderStrong: Color(0x33FFFFFF), // white 20%
    textPrimary: Color(0xFFF5F3FF),
    textSecondary: Color(0xB8F5F3FF),
    textTertiary: Color(0x7AF5F3FF),
    textOnBrand: Color(0xFF0B1426),
    skyGradient: [
      Color(0xFF2D1B4E),
      Color(0xFF1A1B3A),
      Color(0xFF0B1426),
    ],
    isDark: true,
  );

  // -- Dawn sky (light) --
  //
  // Clean, airy morning atmosphere. The previous iteration used a heavily
  // saturated blue→pink→peach gradient which read as "cotton candy" rather
  // than "first light". This palette desaturates towards warm white and
  // swaps the glass surface from black-tinted (muddy on cream) to
  // white-tinted (genuinely frosted). Cards rely on a soft neutral
  // drop-shadow for elevation instead of a violet glow.
  static const dawn = AppPalette(
    bgDeep: Color(0xFFFBF4EC), // near-white warm cream at the horizon
    bgMid: Color(0xFFF1EDFA), // subtle lavender whisper
    bgTop: Color(0xFFE3ECF5), // pale dawn-sky blue
    surfaceGlass: Color(0x99FFFFFF), // white 60% — frosted porcelain
    surfaceGlassElevated: Color(0xB3FFFFFF), // white 70%
    surfaceBorder: Color(0x2E13081F), // near-black 18%
    surfaceBorderStrong: Color(0x4713081F), // near-black 28%
    textPrimary: Color(0xFF13081F), // near-black violet — AAA on sky
    textSecondary: Color(0xD613081F),
    textTertiary: Color(0x9613081F),
    textOnBrand: Color(0xFFFBF4EC),
    skyGradient: [
      Color(0xFFE3ECF5), // top — pale sky blue
      Color(0xFFEFE6F2), // mid — faint lavender wash
      Color(0xFFFBF4EC), // bottom — warm cream horizon
    ],
    isDark: false,
  );

  @override
  AppPalette copyWith({
    Color? bgDeep,
    Color? bgMid,
    Color? bgTop,
    Color? surfaceGlass,
    Color? surfaceGlassElevated,
    Color? surfaceBorder,
    Color? surfaceBorderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textOnBrand,
    List<Color>? skyGradient,
    bool? isDark,
  }) =>
      AppPalette(
        bgDeep: bgDeep ?? this.bgDeep,
        bgMid: bgMid ?? this.bgMid,
        bgTop: bgTop ?? this.bgTop,
        surfaceGlass: surfaceGlass ?? this.surfaceGlass,
        surfaceGlassElevated:
            surfaceGlassElevated ?? this.surfaceGlassElevated,
        surfaceBorder: surfaceBorder ?? this.surfaceBorder,
        surfaceBorderStrong: surfaceBorderStrong ?? this.surfaceBorderStrong,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textTertiary: textTertiary ?? this.textTertiary,
        textOnBrand: textOnBrand ?? this.textOnBrand,
        skyGradient: skyGradient ?? this.skyGradient,
        isDark: isDark ?? this.isDark,
      );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      bgDeep: Color.lerp(bgDeep, other.bgDeep, t)!,
      bgMid: Color.lerp(bgMid, other.bgMid, t)!,
      bgTop: Color.lerp(bgTop, other.bgTop, t)!,
      surfaceGlass: Color.lerp(surfaceGlass, other.surfaceGlass, t)!,
      surfaceGlassElevated:
          Color.lerp(surfaceGlassElevated, other.surfaceGlassElevated, t)!,
      surfaceBorder: Color.lerp(surfaceBorder, other.surfaceBorder, t)!,
      surfaceBorderStrong:
          Color.lerp(surfaceBorderStrong, other.surfaceBorderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textOnBrand: Color.lerp(textOnBrand, other.textOnBrand, t)!,
      skyGradient: [
        for (var i = 0; i < skyGradient.length; i++)
          Color.lerp(
            skyGradient[i],
            i < other.skyGradient.length ? other.skyGradient[i] : skyGradient[i],
            t,
          )!,
      ],
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension PaletteOnContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.night;
}

extension PaletteShadows on AppPalette {
  /// Canonical drop-shadow colour under violet brand elements (CTAs,
  /// avatars, play buttons). Violet glow on dark sky, neutral soft shadow
  /// on dawn cream.
  Color get brandShadow =>
      isDark ? const Color(0x526B5FD9) : const Color(0x29000000);

  /// Softer variant for secondary elements.
  Color get brandShadowSoft =>
      isDark ? const Color(0x336B5FD9) : const Color(0x14000000);
}
