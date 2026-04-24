import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/analytics.dart';
import '../../data/crash_reporter.dart';
import '../../l10n/app_localizations.dart';
import '_profile_support.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(analyticsProvider).track(AnalyticsEvents.aboutOpened));
      unawaited(
        ref.read(crashReporterProvider).breadcrumb(AnalyticsEvents.aboutOpened),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ProfileDetailTopBar(onBack: () => context.pop()),
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
              Text(l.profileAbout, style: AppTypography.displayMd),
              const SizedBox(height: AppSpacing.xl),
              GlassCard(
                glow: GlassGlow.none,
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.mdR,
                      child: Image.asset(
                        'assets/branding/icon.png',
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(l.appName, style: AppTypography.displayMd),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'v$appVersion',
                      style: AppTypography.bodyMd.copyWith(
                        color: context.palette.textTertiary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l.profileAboutTagline,
                      style: AppTypography.bodyMd,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ProfileSectionLabel(l.profileAbout),
              GlassCard(
                padding: EdgeInsets.zero,
                glow: GlassGlow.none,
                child: Column(
                  children: [
                    _LinkRow(
                      label: l.settingsCredits,
                      onTap: () => context.push('/profile/settings/credits'),
                    ),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: context.palette.surfaceBorder,
                    ),
                    _LinkRow(
                      label: l.settingsPrivacy,
                      onTap: () => context.push('/legal/privacy'),
                    ),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: context.palette.surfaceBorder,
                    ),
                    _LinkRow(
                      label: l.settingsTerms,
                      onTap: () => context.push('/legal/terms'),
                    ),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: context.palette.surfaceBorder,
                    ),
                    _LinkRow(
                      label: l.aboutLinkOssLicenses,
                      onTap: () => showLicensePage(
                        context: context,
                        applicationName: l.appName,
                        applicationVersion: appVersion,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Text(
                  l.profileAboutLegalese,
                  style: AppTypography.label.copyWith(
                    color: context.palette.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdR,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: AppTypography.bodyLg),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: context.palette.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
