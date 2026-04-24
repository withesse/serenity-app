import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/states.dart';
import '../../data/progress_store.dart';
import '../../l10n/app_localizations.dart';
import 'progress_data.dart';

class AchievementDetailScreen extends ConsumerWidget {
  const AchievementDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(progressProvider);
    final a = achievementById(state, id);
    if (a == null) {
      return ErrorView(
        title: 'Not found',
        detail: 'That achievement no longer exists.',
        onRetry: () => context.pop(),
      );
    }
    final l = L10n.of(context);
    final unlocked = a.unlocked;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Material(
                color: context.palette.surfaceGlass,
                shape: CircleBorder(
                  side: BorderSide(color: context.palette.surfaceBorder),
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => context.pop(),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(LucideIcons.chevronLeft, size: 22),
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          sliver: SliverList.list(
            children: [
              Center(child: _Badge(unlocked: unlocked)),
              const SizedBox(height: AppSpacing.xl),
              Text(
                a.title,
                style: AppTypography.displayMd,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                a.subtitle,
                style: AppTypography.bodyLg.copyWith(
                  color: context.palette.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              _ProgressCard(achievement: a, l: l),
              const SizedBox(height: AppSpacing.lg),
              _DescriptionCard(metric: a.metric, target: a.target, l: l),
            ],
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.unlocked});
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: unlocked
            ? const RadialGradient(
                colors: [AppColors.brandGold, AppColors.auroraMid],
              )
            : null,
        color: unlocked ? null : context.palette.surfaceGlass,
        border: Border.all(
          color: unlocked
              ? AppColors.brandGold
              : context.palette.surfaceBorder,
          width: 2,
        ),
        boxShadow: unlocked
            ? const [
                BoxShadow(
                  color: AppColors.glowGold,
                  blurRadius: 40,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Icon(
        unlocked ? LucideIcons.trophy : LucideIcons.lock,
        size: 52,
        color: unlocked
            ? context.palette.textOnBrand
            : context.palette.textTertiary,
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.achievement, required this.l});
  final Achievement achievement;
  final L10n l;

  @override
  Widget build(BuildContext context) {
    final progress = achievement.progress.clamp(0, achievement.target);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.achievementProgress, style: AppTypography.label),
              Text(
                '$progress / ${achievement.target} ${_unit(achievement.metric, l)}',
                style: AppTypography.bodyMd.copyWith(
                  color: context.palette.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: achievement.percent,
              minHeight: 10,
              backgroundColor:
                  AppColors.brandViolet.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(
                achievement.unlocked
                    ? AppColors.brandGold
                    : AppColors.brandVioletLight,
              ),
            ),
          ),
          if (!achievement.unlocked) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.achievementRemaining(
                achievement.target - progress,
                _unit(achievement.metric, l),
              ),
              style: AppTypography.label.copyWith(
                color: context.palette.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _unit(AchievementMetric m, L10n l) => switch (m) {
        AchievementMetric.sessions => l.achievementUnitSessions,
        AchievementMetric.streak => l.achievementUnitDays,
        AchievementMetric.minutes => l.achievementUnitMinutes,
      };
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({
    required this.metric,
    required this.target,
    required this.l,
  });
  final AchievementMetric metric;
  final int target;
  final L10n l;

  @override
  Widget build(BuildContext context) {
    final text = switch (metric) {
      AchievementMetric.sessions =>
        l.achievementDescriptionSessions(target),
      AchievementMetric.streak => l.achievementDescriptionStreak(target),
      AchievementMetric.minutes => l.achievementDescriptionMinutes(target),
    };
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Text(
        text,
        style: AppTypography.bodyMd.copyWith(
          color: context.palette.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }
}
