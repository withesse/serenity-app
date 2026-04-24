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
import '../../core/widgets/states.dart';
import '../../data/analytics.dart';
import '../../data/attribution.dart';
import '../../data/crash_reporter.dart';
import '../../data/error_sink.dart';
import '../../l10n/app_localizations.dart';

class CreditsScreen extends ConsumerStatefulWidget {
  const CreditsScreen({super.key});

  @override
  ConsumerState<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends ConsumerState<CreditsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        ref.read(analyticsProvider).track(AnalyticsEvents.creditsOpened),
      );
      unawaited(
        ref
            .read(crashReporterProvider)
            .breadcrumb(AnalyticsEvents.creditsOpened),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              0,
            ),
            child: Text(
              l.settingsCreditsTitle,
              style: AppTypography.displayMd,
            ),
          ),
        ),
        if (bundledAttributions.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: LucideIcons.bookmark,
              title: l.settingsCreditsEmptyTitle,
              subtitle: l.settingsCreditsEmptySubtitle,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            sliver: SliverList.separated(
              itemCount: bundledAttributions.length,
              itemBuilder: (_, index) => _AttributionCard(
                entry: bundledAttributions[index],
              ),
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sm),
            ),
          ),
      ],
    );
  }
}

class _AttributionCard extends ConsumerWidget {
  const _AttributionCard({required this.entry});

  final AttributionEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canOpenSource = entry.sourceUrl != null;
    return GlassCard(
      padding: EdgeInsets.zero,
      glow: GlassGlow.none,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canOpenSource
              ? () => _openSource(context, ref, entry.sourceUrl!)
              : null,
          borderRadius: AppRadius.lgR,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.assetName, style: AppTypography.title),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        entry.author,
                        style: AppTypography.bodyMd.copyWith(
                          color: context.palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.pillR,
                        color: AppColors.brandGold.withValues(alpha: 0.16),
                        border: Border.all(
                          color: AppColors.brandGold.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        entry.licenseName,
                        style: AppTypography.label.copyWith(
                          color: AppColors.brandGold,
                        ),
                      ),
                    ),
                    if (canOpenSource) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Icon(
                        LucideIcons.externalLink,
                        size: 16,
                        color: context.palette.textTertiary,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSource(
      BuildContext context, WidgetRef ref, String rawUrl) async {
    // Snapshot messenger + localized label before awaiting so we don't
    // lean on context across an async gap.
    final messenger = ScaffoldMessenger.maybeOf(context);
    final failureLabel = L10n.of(context).profileHelpLaunchFailed;

    final uri = Uri.tryParse(rawUrl);
    if (uri == null || !uri.hasScheme) {
      reportError(
        ref,
        FormatException('invalid credits source url', rawUrl),
        StackTrace.current,
        context: 'credits_source_invalid',
        data: {'url': rawUrl},
      );
      messenger?.showSnackBar(SnackBar(content: Text(failureLabel)));
      return;
    }
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        reportError(
          ref,
          StateError('launchUrl returned false'),
          StackTrace.current,
          context: 'credits_source_launch_failed',
          data: {'url': rawUrl},
        );
        messenger?.showSnackBar(SnackBar(content: Text(failureLabel)));
      }
    } catch (e, st) {
      reportError(ref, e, st,
          context: 'credits_source_launch_failed',
          data: {'url': rawUrl});
      messenger?.showSnackBar(SnackBar(content: Text(failureLabel)));
    }
  }
}
