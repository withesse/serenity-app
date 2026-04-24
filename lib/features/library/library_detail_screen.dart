import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/share.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/download_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/pill_button.dart';
import '../../core/widgets/states.dart';
import '../../data/favourites_store.dart';
import '../../data/library_repository.dart';
import '../../l10n/app_localizations.dart';
import 'library_data.dart';

/// Shared helper: in dawn mode the session's native gradient reads as a
/// dark slab against the cream backdrop. Lerp each stop toward white so
/// the colour identity survives but the weight drops.
List<Color> _softenForPalette(BuildContext context, List<Color> raw) {
  if (context.palette.isDark) return raw;
  return raw
      .map((c) => Color.lerp(c, const Color(0xFFFFFFFF), 0.55)!)
      .toList();
}

/// Detail-hero version: keeps the top band vivid and fades to transparent.
List<Color> _heroGradient(BuildContext context, LibrarySession s) {
  final soften = !context.palette.isDark;
  Color top = s.gradient.first;
  Color mid = s.gradient.last;
  if (soften) {
    top = Color.lerp(top, const Color(0xFFFFFFFF), 0.40)!;
    mid = Color.lerp(mid, const Color(0xFFFFFFFF), 0.55)!;
  }
  return [
    top.withValues(alpha: 0.8),
    mid.withValues(alpha: 0.4),
    const Color(0x00000000),
  ];
}

class LibraryDetailScreen extends ConsumerWidget {
  const LibraryDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(libraryRepositoryProvider);
    final session = repo.findById(sessionId);
    if (session == null) {
      return ErrorView(
        title: 'Session not found',
        detail: 'It may have been removed or is no longer available.',
        onRetry: () => context.go('/library'),
      );
    }

    final related = repo.related(session);
    final l = L10n.of(context);
    final t = session.localized(Localizations.localeOf(context));

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _Hero(session: session, onClose: () => context.pop()),
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
              Text(l.libraryDetailAbout, style: AppTypography.label),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${t.tagline}\n\n${l.libraryDetailLongDescription(t.narrator, session.durationLabelFor(l))}',
                style: AppTypography.bodyLg.copyWith(
                  color: context.palette.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PillButton(
                label: l.libraryDetailBegin,
                icon: LucideIcons.play,
                onPressed: () =>
                    context.push('/player/${session.id}'),
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: DownloadButton(sessionId: session.id),
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (related.isNotEmpty) ...[
                Text(
                  l.libraryDetailMoreIn(session.category.labelLocalized(l)),
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.md),
                for (final other in related) ...[
                  _RelatedTile(session: other),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Hero extends ConsumerWidget {
  const _Hero({required this.session, required this.onClose});
  final LibrarySession session;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favourited = ref.watch(
      favouritesProvider.select((s) => s.contains(session.id)),
    );
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.sm,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _heroGradient(context, session),
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                color: context.palette.surfaceGlass,
                shape: CircleBorder(
                  side: BorderSide(color: context.palette.surfaceBorder),
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onClose,
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(LucideIcons.chevronLeft, size: 22),
                  ),
                ),
              ),
              const Spacer(),
              Builder(
                builder: (btnCtx) => Material(
                  color: context.palette.surfaceGlass,
                  shape: CircleBorder(
                    side: BorderSide(color: context.palette.surfaceBorder),
                  ),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => shareSession(btnCtx, session, ref: ref),
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(LucideIcons.share, size: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Material(
                color: context.palette.surfaceGlass,
                shape: CircleBorder(
                  side: BorderSide(color: context.palette.surfaceBorder),
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => ref
                      .read(favouritesProvider.notifier)
                      .toggle(session.id),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      favourited ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: favourited ? AppColors.brandGold : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.smR,
              color: context.palette.surfaceGlass,
              border: Border.all(color: context.palette.surfaceBorder),
            ),
            child: Text(
              session.category.labelLocalized(L10n.of(context)).toUpperCase(),
              style: AppTypography.label.copyWith(
                color: context.palette.textPrimary,
                fontSize: 10,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Builder(builder: (ctx) {
            final t = session.localized(Localizations.localeOf(ctx));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.title, style: AppTypography.displayMd),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(LucideIcons.clock,
                        size: 14, color: context.palette.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      session.durationLabelFor(L10n.of(ctx)),
                      style: AppTypography.bodyMd,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Icon(LucideIcons.user,
                        size: 14, color: context.palette.textSecondary),
                    const SizedBox(width: 4),
                    Text(t.narrator, style: AppTypography.bodyMd),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _RelatedTile extends StatelessWidget {
  const _RelatedTile({required this.session});
  final LibrarySession session;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () => context.pushReplacement('/library/session/${session.id}'),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdR,
              gradient: LinearGradient(
                colors: _softenForPalette(context, session.gradient),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              LucideIcons.play,
              color: Color(0xFFF5F3FF),
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Builder(builder: (ctx) {
              final t = session.localized(Localizations.localeOf(ctx));
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title, style: AppTypography.title),
                  const SizedBox(height: 2),
                  Text(
                    '${session.durationLabelFor(L10n.of(ctx))} · ${t.narrator}',
                    style: AppTypography.bodyMd,
                  ),
                ],
              );
            }),
          ),
          Icon(
            LucideIcons.chevronRight,
            color: context.palette.textTertiary,
            size: 18,
          ),
        ],
      ),
    );
  }
}
