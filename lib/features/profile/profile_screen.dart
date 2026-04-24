import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/auth_store.dart';
import '../../data/iap_store.dart';
import '../../data/progress_store.dart';
import '../../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final auth = ref.watch(authProvider);
    final iap = ref.watch(iapProvider);
    final l = L10n.of(context);
    final displayName = auth.user?.displayName ?? l.profileDisplayNameFallback;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          sliver: SliverList.list(
            children: [
              _UserHeader(displayName: displayName),
              const SizedBox(height: AppSpacing.xl),
              _MiniStats(
                streak: progress.currentStreak,
                total: progress.totalMinutes,
                sessions: progress.sessionsCompleted,
                streakLabel: l.profileStatStreak,
                streakUnit: l.profileStatDaysShort,
                minutesLabel: l.profileStatMinutes,
                sessionsLabel: l.profileStatSessions,
              ),
              const SizedBox(height: AppSpacing.xl),
              _MenuTile(
                icon: LucideIcons.lineChart,
                label: l.profileProgress,
                subtitle: l.profileProgressSubtitle,
                onTap: () => context.push('/profile/progress'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _MenuTile(
                icon: LucideIcons.crown,
                label: l.profilePremium,
                subtitle: l.profilePremiumSubtitle,
                trailingBadge: iap.isPremium
                    ? l.profilePremiumActive
                    : l.profilePremiumTrial,
                onTap: () => context.push('/profile/premium'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _MenuTile(
                icon: LucideIcons.settings,
                label: l.profileSettings,
                subtitle: l.profileSettingsSubtitle,
                onTap: () => context.push('/profile/settings'),
              ),
              const SizedBox(height: AppSpacing.xl),
              _MenuTile(
                icon: LucideIcons.helpCircle,
                label: l.profileHelp,
                key: const Key('profile-row-help'),
                onTap: () => context.push('/profile/help'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _MenuTile(
                icon: LucideIcons.info,
                label: l.profileAbout,
                key: const Key('profile-row-about'),
                onTap: () => context.push('/profile/about'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    final trimmedName = displayName.trim();
    final avatarLetter = trimmedName.isEmpty
        ? ''
        : trimmedName.substring(0, 1).toUpperCase();
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: AppColors.auroraGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: context.palette.brandShadow,
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              avatarLetter,
              style: AppTypography.headline.copyWith(
                fontSize: 28,
                color: context.palette.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(L10n.of(context).homeGreetingEvening,
                  style: AppTypography.bodyMd),
              const SizedBox(height: 2),
              Text(displayName, style: AppTypography.displayMd),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniStats extends StatelessWidget {
  const _MiniStats({
    required this.streak,
    required this.total,
    required this.sessions,
    required this.streakLabel,
    required this.streakUnit,
    required this.minutesLabel,
    required this.sessionsLabel,
  });
  final int streak;
  final int total;
  final int sessions;
  final String streakLabel;
  final String streakUnit;
  final String minutesLabel;
  final String sessionsLabel;

  @override
  Widget build(BuildContext context) {
    final divider = Container(
      width: 1,
      height: 36,
      color: context.palette.surfaceBorder,
    );
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: _Stat(
              value: '$streak',
              label: streakLabel,
              unit: streakUnit,
            ),
          ),
          divider,
          Expanded(
            child: _Stat(value: '$total', label: minutesLabel),
          ),
          divider,
          Expanded(
            child: _Stat(value: '$sessions', label: sessionsLabel),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.unit});
  final String value;
  final String label;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: AppTypography.duration.copyWith(
                fontSize: 24,
                color: context.palette.textPrimary,
              ),
            ),
            if (unit != null) ...[
              const SizedBox(width: 2),
              Text(unit!, style: AppTypography.bodyMd),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.label.copyWith(
            color: context.palette.textTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.trailingBadge,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? subtitle;
  final String? trailingBadge;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandViolet.withValues(alpha: 0.25),
              border: Border.all(color: context.palette.surfaceBorder),
            ),
            child: Icon(icon, size: 18, color: context.palette.textPrimary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.title),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppTypography.bodyMd),
                ],
              ],
            ),
          ),
          if (trailingBadge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                borderRadius: AppRadius.smR,
                color: AppColors.brandGold.withValues(alpha: 0.2),
                border: Border.all(color: AppColors.brandGold),
              ),
              child: Text(
                trailingBadge!,
                style: AppTypography.label.copyWith(
                  color: AppColors.brandGold,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Icon(
            LucideIcons.chevronRight,
            size: 18,
            color: context.palette.textTertiary,
          ),
        ],
      ),
    );
  }
}
