import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'aurora_background.dart';
import 'glass_card.dart';
import 'star_field.dart';

/// Placeholder used while a feature screen is not yet implemented. Shows the
/// title, a short sub-copy, and the full visual foundation so that navigation
/// can be demoed end-to-end.
class StubScreen extends StatelessWidget {
  const StubScreen({
    super.key,
    required this.title,
    this.subtitle = 'Coming soon',
    this.wrap = true,
  });

  final String title;
  final String subtitle;

  /// If true, wrap in AuroraBackground + StarField. Use `false` when this stub
  /// is nested inside [AppShell], which already provides the background.
  final bool wrap;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTypography.displayMd,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                subtitle,
                style: AppTypography.bodyMd.copyWith(
                  color: context.palette.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    if (!wrap) return content;

    return AuroraBackground(
      child: Stack(
        children: [
          const Positioned.fill(child: StarField()),
          Positioned.fill(child: SafeArea(child: content)),
        ],
      ),
    );
  }
}
