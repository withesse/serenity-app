import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';

enum GlassGlow { none, soft, gold }

/// Canonical glass surface. Mirrors MASTER.md §7 recipe:
///   backdrop-filter: blur(20)
///   background:      rgba(255,255,255,0.06) (or 0.10 when elevated)
///   border:          1px rgba(255,255,255,0.12)
///   radius:          lg (24)
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.borderRadius = AppRadius.lgR,
    this.elevated = false,
    this.glow = GlassGlow.soft,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final bool elevated;
  final GlassGlow glow;
  final VoidCallback? onTap;

  /// Optional VoiceOver label for tappable cards. When the card is a simple
  /// passive container (no [onTap]) this can be left null and the child
  /// `Text` widgets carry their own semantics.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = context.palette.isDark;
    // Dark mode uses coloured glows (the brand aesthetic); light mode needs
    // neutral depth instead, otherwise every card drags a violet halo across
    // the cream backdrop.
    final shadow = switch (glow) {
      GlassGlow.none => const <BoxShadow>[],
      GlassGlow.soft => isDark
          ? const [
              BoxShadow(
                color: AppColors.glowViolet,
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ]
          : const [
              BoxShadow(
                color: Color(0x1F000000), // black 12%
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
      GlassGlow.gold => isDark
          ? const [
              BoxShadow(
                color: AppColors.glowGold,
                blurRadius: 40,
                spreadRadius: 2,
                offset: Offset(0, 0),
              ),
              BoxShadow(
                color: AppColors.glowGoldSoft,
                blurRadius: 72,
                offset: Offset(0, 12),
              ),
            ]
          : const [
              BoxShadow(
                color: AppColors.glowGoldSoft,
                blurRadius: 36,
                spreadRadius: 1,
                offset: Offset(0, 12),
              ),
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
    };

    final inner = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: shadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Material(
            color: elevated
                ? context.palette.surfaceGlassElevated
                : context.palette.surfaceGlass,
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: context.palette.surfaceBorder,
                    width: 1,
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );

    // If the card is tappable we expose it as a single Semantics button so
    // VoiceOver announces the whole region, not the nested Text nodes.
    if (onTap != null) {
      return Semantics(
        button: true,
        label: semanticLabel,
        child: inner,
      );
    }
    return inner;
  }
}
