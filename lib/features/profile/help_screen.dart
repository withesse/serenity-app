import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/analytics.dart';
import '../../data/crash_reporter.dart';
import '../../l10n/app_localizations.dart';
import '_profile_support.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(analyticsProvider).track(AnalyticsEvents.helpOpened));
      unawaited(
        ref.read(crashReporterProvider).breadcrumb(AnalyticsEvents.helpOpened),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final faq = [
      (question: l.helpFaqQ1, answer: l.helpFaqA1),
      (question: l.helpFaqQ2, answer: l.helpFaqA2),
      (question: l.helpFaqQ3, answer: l.helpFaqA3),
      (question: l.helpFaqQ4, answer: l.helpFaqA4),
      (question: l.helpFaqQ5, answer: l.helpFaqA5),
      (question: l.helpFaqQ6, answer: l.helpFaqA6),
    ];

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
              Text(l.profileHelp, style: AppTypography.displayMd),
              const SizedBox(height: AppSpacing.xl),
              ProfileSectionLabel(l.helpFaqTitle),
              GlassCard(
                padding: EdgeInsets.zero,
                glow: GlassGlow.none,
                child: Column(
                  children: [
                    for (var i = 0; i < faq.length; i++) ...[
                      Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            0,
                            AppSpacing.md,
                            AppSpacing.md,
                          ),
                          iconColor: context.palette.textSecondary,
                          collapsedIconColor: context.palette.textSecondary,
                          title: Text(
                            faq[i].question,
                            style: AppTypography.bodyLg,
                          ),
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                faq[i].answer,
                                style: AppTypography.bodyMd.copyWith(
                                  color: context.palette.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (i < faq.length - 1)
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: context.palette.surfaceBorder,
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ProfileSectionLabel(l.helpContactTitle),
              GlassCard(
                borderRadius: AppRadius.pillR,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                onTap: () {
                  unawaited(
                    ref.read(analyticsProvider).track(
                      AnalyticsEvents.helpContactTapped,
                      {'target': supportEmail},
                    ),
                  );
                  unawaited(
                    ref.read(crashReporterProvider).breadcrumb(
                      AnalyticsEvents.helpContactTapped,
                      data: {'target': supportEmail},
                    ),
                  );
                  unawaited(
                    openSupportEmail(context, launcher: launchUrl),
                  );
                },
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
                      child: Icon(
                        LucideIcons.mail,
                        size: 18,
                        color: context.palette.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        supportEmail,
                        style: AppTypography.bodyLg,
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: context.palette.textTertiary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ProfileSectionLabel(l.helpDiagnosticsTitle),
              GlassCard(
                glow: GlassGlow.none,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.helpDiagnosticsHint,
                      style: AppTypography.bodyMd.copyWith(
                        color: context.palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l.helpDiagnosticsVersion(appVersion),
                      style: AppTypography.bodyLg,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l.helpDiagnosticsLocale(locale),
                      style: AppTypography.bodyLg,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
