import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../l10n/app_localizations.dart';
import 'breathing_techniques.dart';

class BreatheScreen extends StatelessWidget {
  const BreatheScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          sliver: SliverList.list(
            children: [
              Text(l.breatheTitle, style: AppTypography.bodyMd),
              const SizedBox(height: AppSpacing.xs),
              Text(l.breatheHeadline, style: AppTypography.displayMd),
              const SizedBox(height: AppSpacing.md),
              Text(
                l.breatheSubtitle,
                style: AppTypography.bodyLg.copyWith(
                  color: context.palette.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              for (var i = 0; i < breathingTechniques.length; i++) ...[
                _TechniqueCard(
                  key: Key('breathe-technique-${breathingTechniques[i].id}'),
                  technique: breathingTechniques[i],
                ),
                if (i < breathingTechniques.length - 1)
                  const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TechniqueCard extends StatelessWidget {
  const _TechniqueCard({super.key, required this.technique});
  final BreathingTechnique technique;

  @override
  Widget build(BuildContext context) {
    final t = technique.localized(Localizations.localeOf(context));
    return GlassCard(
      onTap: () => context.push('/breathe/session', extra: technique.id),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Decorative badge next to each technique. On dark it's the bold
          // brand gradient; on dawn the same gradient would punch through as
          // a heavy blue/violet disk, so we soften to a pastel variant and
          // switch the icon to dark so it still reads at 24px.
          Builder(builder: (context) {
            final isDark = context.palette.isDark;
            return Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isDark
                      ? AppColors.violetAuroraGradient
                      : const [Color(0xFFDED8F6), Color(0xFFCBD5F0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.palette.brandShadowSoft,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                LucideIcons.wind,
                size: 24,
                color: isDark
                    ? context.palette.textPrimary
                    : AppColors.brandViolet,
              ),
            );
          }),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.name, style: AppTypography.title),
                const SizedBox(height: 2),
                Text(
                  t.tagline,
                  style: AppTypography.bodyMd,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _Chip(label: technique.pattern),
                    const SizedBox(width: AppSpacing.sm),
                    _Chip(
                      label: L10n.of(context)
                          .commonDurationMinutes(technique.durationMinutes),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            LucideIcons.chevronRight,
            size: 20,
            color: context.palette.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.smR,
        color: context.palette.surfaceGlass,
        border: Border.all(color: context.palette.surfaceBorder, width: 1),
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(
          color: context.palette.textSecondary,
          fontSize: 11,
        ),
      ),
    );
  }
}
