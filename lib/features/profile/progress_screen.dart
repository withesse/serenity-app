import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/insights.dart';
import '../../data/mood_store.dart';
import '../../data/progress_store.dart';
import '../../l10n/app_localizations.dart';
import 'progress_data.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(progressProvider);
    final l = L10n.of(context);

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
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          sliver: SliverList.list(
            children: [
              Text(l.progressTitle, style: AppTypography.bodyMd),
              const SizedBox(height: AppSpacing.xs),
              Text(l.progressHeadline, style: AppTypography.displayMd),
              const SizedBox(height: AppSpacing.xl),
              _StreakCard(
                streak: data.currentStreak,
                freezeAvailable: data.freezeAvailable,
              ),
              const SizedBox(height: AppSpacing.md),
              _StatRow(
                total: data.totalMinutes,
                sessions: data.sessionsCompleted,
                longest: data.longestStreak,
              ),
              const SizedBox(height: AppSpacing.xl),
              const _InsightsCard(),
              const SizedBox(height: AppSpacing.xl),
              Text(l.progressLast35Days, style: AppTypography.title),
              const SizedBox(height: AppSpacing.sm),
              Text(l.progressLast35DaysHint, style: AppTypography.bodyMd),
              const SizedBox(height: AppSpacing.md),
              _Heatmap(days: data.days),
              const SizedBox(height: AppSpacing.xl),
              Text(l.progressMoodHeading, style: AppTypography.title),
              const SizedBox(height: AppSpacing.sm),
              Text(l.progressMoodHint, style: AppTypography.bodyMd),
              const SizedBox(height: AppSpacing.md),
              const _MoodStrip(),
              const SizedBox(height: AppSpacing.xl),
              Text(l.progressAchievements, style: AppTypography.title),
              const SizedBox(height: AppSpacing.md),
              for (final a in data.achievements) ...[
                _AchievementTile(achievement: a),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.streak,
    required this.freezeAvailable,
  });
  final int streak;
  final bool freezeAvailable;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return GlassCard(
      glow: GlassGlow.gold,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      LucideIcons.moon,
                      size: 18,
                      color: AppColors.brandGold,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(l.progressCurrentStreak, style: AppTypography.label),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '$streak',
                  style: AppTypography.timer.copyWith(
                    fontSize: 72,
                    color: AppColors.brandGold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.progressNightsInARow(streak),
                  style: AppTypography.bodyMd,
                ),
                const SizedBox(height: AppSpacing.sm),
                Tooltip(
                  message: l.progressFreezeHint,
                  child: _FreezeChip(available: freezeAvailable),
                ),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.brandGold.withValues(alpha: 0.4),
                  AppColors.brandGold.withValues(alpha: 0),
                ],
              ),
            ),
            child: const Icon(
              LucideIcons.sparkles,
              size: 32,
              color: AppColors.brandGold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FreezeChip extends StatelessWidget {
  const _FreezeChip({required this.available});
  final bool available;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final tint = available
        ? const Color(0xFF9BA4E5) // pale frost
        : context.palette.textTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.pillR,
        color: context.palette.surfaceGlass,
        border: Border.all(
          color: available
              ? tint.withValues(alpha: 0.4)
              : context.palette.surfaceBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.snowflake, size: 12, color: tint),
          const SizedBox(width: 4),
          Text(
            available ? l.progressFreezeAvailable : l.progressFreezeUsed,
            style: AppTypography.label.copyWith(
              color: tint,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.total,
    required this.sessions,
    required this.longest,
  });
  final int total;
  final int sessions;
  final int longest;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return Row(
      children: [
        Expanded(
          child: _StatCell(
            label: l.progressTotal,
            value: '$total',
            unit: 'min',
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCell(
            label: l.progressSessions,
            value: '$sessions',
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCell(
            label: l.progressLongest,
            value: '$longest',
            unit: 'd',
          ),
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value, this.unit});
  final String label;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: context.palette.textTertiary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTypography.duration.copyWith(
                    fontSize: 28,
                    color: context.palette.textPrimary,
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 4),
                  Text(unit!, style: AppTypography.bodyMd),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.days});
  final List<DayEntry> days;

  static const _cols = 7;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final size = (constraints.maxWidth - (_cols - 1) * 6) / _cols;
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final d in days) _HeatCell(day: d, size: size),
          ],
        );
      },
    );
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({required this.day, required this.size});
  final DayEntry day;
  final double size;

  Color _color(BuildContext context) {
    // Max expected intensity around 25 min.
    // Zero-minute cells are subtle — white-ish on dark, a shade of the
    // violet tint on light (so empty days don't read as bright white
    // squares against the cream sky).
    if (day.minutes == 0) {
      return context.palette.isDark
          ? context.palette.surfaceGlass
          : AppColors.brandViolet.withValues(alpha: 0.08);
    }
    final t = (day.minutes / 25).clamp(0, 1).toDouble();
    return Color.lerp(
      AppColors.brandViolet.withValues(alpha: 0.25),
      AppColors.brandGold,
      t,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _color(context),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: context.palette.surfaceBorder, width: 0.5),
        boxShadow: day.minutes > 15
            ? const [
                BoxShadow(
                  color: AppColors.glowGold,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }
}

class _MoodStrip extends ConsumerWidget {
  const _MoodStrip();

  static const _emojis = ['😔', '😐', '🙂', '😌', '✨'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(moodProvider);
    final recent = ref.read(moodProvider.notifier).recent(7);
    if (recent.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          L10n.of(context).progressMoodEmpty,
          style: AppTypography.bodyMd.copyWith(
            color: context.palette.textSecondary,
          ),
        ),
      );
    }
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final entry in recent)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _emojis[(entry.mood - 1).clamp(0, _emojis.length - 1)],
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 4),
                Text(
                  _shortDay(entry.date),
                  style: AppTypography.label.copyWith(
                    color: context.palette.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  static String _shortDay(DateTime d) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[(d.weekday - 1) % 7];
  }
}

class _InsightsCard extends ConsumerWidget {
  const _InsightsCard();

  static const _moodEmojis = ['😔', '😐', '🙂', '😌', '✨'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(weeklyInsightsProvider);
    final l = L10n.of(context);
    final delta = insights.minutesDelta;
    final String? deltaText = delta == 0
        ? (insights.minutesThisWeek == 0 ? null : l.progressWeekDeltaSame)
        : delta > 0
            ? l.progressWeekDeltaUp(delta)
            : l.progressWeekDeltaDown(-delta);
    final double? mood = insights.averageMood;
    final String? moodEmoji = mood == null
        ? null
        : _moodEmojis[(mood.round() - 1).clamp(0, _moodEmojis.length - 1)];

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles,
                  size: 16, color: AppColors.brandGold),
              const SizedBox(width: AppSpacing.sm),
              Text(l.progressThisWeek, style: AppTypography.label),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l.progressThisWeekSummary(
              insights.daysPracticed,
              insights.minutesThisWeek,
            ),
            style: AppTypography.title.copyWith(height: 1.3),
          ),
          if (deltaText != null) ...[
            const SizedBox(height: 4),
            Text(
              deltaText,
              style: AppTypography.bodyMd.copyWith(
                color: delta > 0
                    ? AppColors.brandGold
                    : context.palette.textSecondary,
              ),
            ),
          ],
          if (moodEmoji != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              l.progressMoodAverage(moodEmoji),
              style: AppTypography.bodyMd.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement});
  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.unlocked;
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glow: unlocked ? GlassGlow.gold : GlassGlow.none,
      onTap: () => context.push(
        '/profile/progress/achievement/${achievement.id}',
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: unlocked
                  ? const RadialGradient(
                      colors: [
                        AppColors.brandGold,
                        AppColors.auroraMid,
                      ],
                    )
                  : null,
              color: unlocked ? null : context.palette.surfaceGlass,
              border: Border.all(
                color: unlocked
                    ? AppColors.brandGold
                    : context.palette.surfaceBorder,
              ),
            ),
            child: Icon(
              unlocked ? LucideIcons.trophy : LucideIcons.lock,
              size: 18,
              color: unlocked
                  ? context.palette.textOnBrand
                  : context.palette.textTertiary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: AppTypography.title.copyWith(
                    color: unlocked
                        ? context.palette.textPrimary
                        : context.palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.subtitle,
                  style: AppTypography.bodyMd,
                ),
              ],
            ),
          ),
          if (unlocked)
            const Icon(
              LucideIcons.check,
              size: 18,
              color: AppColors.brandGold,
            ),
        ],
      ),
    );
  }
}
