import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/states.dart';
import '../../data/analytics.dart';
import '../../data/crash_reporter.dart';
import '../../data/downloads_store.dart';
import '../../data/library_repository.dart';
import '../../l10n/app_localizations.dart';
import 'library_data.dart';

String _categoryLabel(LibraryCategory c, L10n l) => c.labelLocalized(l);

enum _OwnershipFilter { all, offlineOnly }

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  LibraryCategory _selected = LibraryCategory.all;
  _OwnershipFilter _ownershipFilter = _OwnershipFilter.all;
  String _query = '';

  void _setOwnershipFilter(_OwnershipFilter value) {
    setState(() => _ownershipFilter = value);
    final active = value == _OwnershipFilter.offlineOnly;
    unawaited(
      ref.read(analyticsProvider).track(
        AnalyticsEvents.libraryOfflineFilterToggled,
        {'active': active},
      ),
    );
    unawaited(
      ref.read(crashReporterProvider).breadcrumb(
        AnalyticsEvents.libraryOfflineFilterToggled,
        data: {'active': active},
      ),
    );
  }

  List<LibrarySession> _filteredFor(Locale? locale) {
    final repo = ref.read(libraryRepositoryProvider);
    Iterable<LibrarySession> filtered = repo.byCategory(_selected);
    if (_ownershipFilter == _OwnershipFilter.offlineOnly) {
      filtered = filtered.where(
        (s) => ref.watch(downloadEntryProvider(s.id)).isDone,
      );
    }
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return filtered.toList();
    // Match against both the English original and the localized copy so a
    // Chinese speaker can find a session by its zh title without falling
    // through to the English string.
    return filtered.where((s) {
      final l = s.localized(locale);
      return s.title.toLowerCase().contains(q) ||
          s.narrator.toLowerCase().contains(q) ||
          s.tagline.toLowerCase().contains(q) ||
          l.title.toLowerCase().contains(q) ||
          l.narrator.toLowerCase().contains(q) ||
          l.tagline.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final filtered = _filteredFor(Localizations.localeOf(context));
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          sliver: SliverList.list(
            children: [
              Text(l.libraryTitle, style: AppTypography.bodyMd),
              const SizedBox(height: AppSpacing.xs),
              Text(l.libraryHeadline, style: AppTypography.displayMd),
              const SizedBox(height: AppSpacing.lg),
              _SearchBar(
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: _CategoryChips(
            selected: _selected,
            ownershipFilter: _ownershipFilter,
            onSelect: (c) => setState(() => _selected = c),
            onSelectOwnership: _setOwnershipFilter,
          ),
        ),
        if (filtered.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: LucideIcons.searchX,
              title: l.libraryEmptyTitle,
              subtitle: l.libraryEmptySubtitle,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.78,
              children: [
                for (final session in filtered)
                  _SessionTile(
                    key: Key('library-session-${session.id}'),
                    session: session,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: AppRadius.pillR,
        color: context.palette.surfaceGlass,
        border: Border.all(color: context.palette.surfaceBorder),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.search,
            size: 18,
            color: context.palette.textTertiary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: AppTypography.bodyMd.copyWith(
                color: context.palette.textPrimary,
              ),
              cursorColor: context.palette.textPrimary,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: L10n.of(context).librarySearch,
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: context.palette.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.selected,
    required this.ownershipFilter,
    required this.onSelect,
    required this.onSelectOwnership,
  });
  final LibraryCategory selected;
  final _OwnershipFilter ownershipFilter;
  final ValueChanged<LibraryCategory> onSelect;
  final ValueChanged<_OwnershipFilter> onSelectOwnership;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          for (final c in LibraryCategory.values) ...[
            _Chip(
              key: Key('library-chip-${c.name}'),
              label: _categoryLabel(c, l),
              selected: c == selected,
              onTap: () => onSelect(c),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          _Chip(
            key: const Key('library-chip-offline'),
            label: l.libraryFilterOfflineOnly,
            selected: ownershipFilter == _OwnershipFilter.offlineOnly,
            onTap: () => onSelectOwnership(
              ownershipFilter == _OwnershipFilter.offlineOnly
                  ? _OwnershipFilter.all
                  : _OwnershipFilter.offlineOnly,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.brandViolet.withValues(alpha: 0.35)
          : context.palette.surfaceGlass,
      borderRadius: AppRadius.pillR,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pillR,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.pillR,
            border: Border.all(
              color: selected
                  ? AppColors.brandVioletLight
                  : context.palette.surfaceBorder,
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: AppColors.glowViolet,
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AppTypography.label.copyWith(
              color: selected
                  ? context.palette.textPrimary
                  : context.palette.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionTile extends ConsumerWidget {
  const _SessionTile({super.key, required this.session});
  final LibrarySession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloaded =
        ref.watch(downloadEntryProvider(session.id)).isDone;
    final isDark = context.palette.isDark;
    // Dawn cards use a pastel variant of the session gradient so they sit
    // lightly on the cream sky instead of punching through as dark slabs.
    final gradient = isDark
        ? session.gradient
        : session.gradient
            .map((c) => Color.lerp(c, const Color(0xFFFFFFFF), 0.55)!)
            .toList();
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.lgR,
      child: InkWell(
        onTap: () => context.push('/library/session/${session.id}'),
        borderRadius: AppRadius.lgR,
        child: ClipRRect(
          borderRadius: AppRadius.lgR,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.lgR,
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: context.palette.surfaceBorder),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? AppColors.glowViolet
                      : const Color(0x14000000),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Builder(builder: (ctx) {
                final t = session.localized(Localizations.localeOf(ctx));
                return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CategoryBadge(category: session.category),
                      const Spacer(),
                      if (downloaded)
                        Icon(
                          LucideIcons.arrowDownCircle,
                          size: 14,
                          color: context.palette.textTertiary,
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    t.title,
                    style: AppTypography.title.copyWith(height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.clock,
                        size: 12,
                        color: context.palette.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        session.durationLabelFor(L10n.of(ctx)),
                        style: AppTypography.label
                            .copyWith(color: context.palette.textTertiary),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '·',
                        style: AppTypography.label
                            .copyWith(color: context.palette.textTertiary),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          t.narrator,
                          style: AppTypography.label.copyWith(
                            color: context.palette.textTertiary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});
  final LibraryCategory category;

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
        border: Border.all(color: context.palette.surfaceBorder),
      ),
      child: Text(
        _categoryLabel(category, L10n.of(context)),
        style: AppTypography.label.copyWith(
          color: context.palette.textPrimary,
          fontSize: 10,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
