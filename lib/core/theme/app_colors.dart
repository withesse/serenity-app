import 'package:flutter/material.dart';

/// Theme-invariant color constants. These read identically against any
/// background (dark or light). Swap-aware tokens — surfaces, backgrounds,
/// text — live on [AppPalette] and are accessed via `context.palette`.
class AppColors {
  AppColors._();

  // -- Brand (constant across themes) --
  static const Color brandViolet = Color(0xFF6B5FD9);
  static const Color brandVioletLight = Color(0xFF8B7FEB);
  static const Color brandGold = Color(0xFFE8C547);

  // -- Aurora accents --
  static const Color auroraStart = Color(0xFF6366F1);
  static const Color auroraMid = Color(0xFFA855F7);
  static const Color auroraEnd = Color(0xFFEC4899);

  static const List<Color> auroraGradient = [
    auroraStart,
    auroraMid,
    auroraEnd,
  ];

  static const List<Color> violetAuroraGradient = [brandViolet, auroraStart];

  // -- Semantic --
  static const Color success = Color(0xFFA7F3D0);
  static const Color warning = Color(0xFFFDE68A);
  static const Color error = Color(0xFFF87171);

  // -- Glow helpers (for BoxShadow) — theme-invariant colored bloom --
  static const Color glowViolet = Color(0x336B5FD9); // 0.20
  static const Color glowVioletStrong = Color(0x526B5FD9); // 0.32
  static const Color glowGold = Color(0x70E8C547); // 0.44
  static const Color glowGoldSoft = Color(0x3AE8C547); // 0.23
}
