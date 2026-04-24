import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/clock.dart';
import '../../data/profile_store.dart';
import '../../l10n/app_localizations.dart';
import '../library/library_data.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L10n.of(context);
    final goals = ref.watch(profileProvider.select((p) => p.goals));
    final tonight = tonightRecommendation(
      goals: goals,
      now: ref.read(clockProvider)(),
    );
    final t = tonight.localized(Localizations.localeOf(context));
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.homeGreetingEvening, style: AppTypography.bodyMd),
                const SizedBox(height: AppSpacing.xs),
                Text(l.homeHeadline, style: AppTypography.displayMd),
                const SizedBox(height: AppSpacing.xl),
                GlassCard(
                  key: const Key('home-tonight-card'),
                  glow: GlassGlow.gold,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  onTap: () => context.push('/player/${tonight.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.brightness_2_outlined,
                              color: AppColors.brandGold, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text(l.homeTonight,
                              style: AppTypography.label),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(t.title, style: AppTypography.headline),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${tonight.durationLabelFor(l)} · ${t.narrator} · ${tonight.category.labelLocalized(l)}',
                        style: AppTypography.bodyMd,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(l.homeQuickStart, style: AppTypography.title),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        onTap: () =>
                            context.push('/breathe/session', extra: 'box'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.air,
                                color: AppColors.brandVioletLight),
                            const SizedBox(height: AppSpacing.sm),
                            Text('Box Breathing',
                                style: AppTypography.title),
                            Text(l.commonDurationMinutes(3),
                                style: AppTypography.bodyMd),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        onTap: () =>
                            context.push('/player/deep-sleep-story'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.nightlight_round,
                                color: AppColors.brandVioletLight),
                            const SizedBox(height: AppSpacing.sm),
                            Text('Sleep Story',
                                style: AppTypography.title),
                            Text(l.commonDurationMinutes(20),
                                style: AppTypography.bodyMd),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
