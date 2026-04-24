import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../features/profile/medical_disclaimer_dialog.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'aurora_background.dart';
import 'star_field.dart';

/// Root scaffold for tab routes. Wraps child with AuroraBackground + StarField
/// and renders a glass bottom navigation bar with 4 tabs.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _paths = ['/home', '/library', '/breathe', '/profile'];
  static const _icons = [
    LucideIcons.home,
    LucideIcons.library,
    LucideIcons.wind,
    LucideIcons.user,
  ];

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    for (var i = 0; i < _paths.length; i++) {
      if (loc.startsWith(_paths[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final tabs = <_TabItem>[
      _TabItem(_paths[0], _icons[0], l.tabHome),
      _TabItem(_paths[1], _icons[1], l.tabLibrary),
      _TabItem(_paths[2], _icons[2], l.tabBreathe),
      _TabItem(_paths[3], _icons[3], l.tabProfile),
    ];

    return MedicalDisclaimerGate(
      child: AuroraBackground(
        child: Stack(
          children: [
            const Positioned.fill(child: StarField()),
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 92),
                  child: child,
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: _BottomNav(
                tabs: tabs,
                currentIndex: _currentIndex(context),
                onTap: (i) => context.go(tabs[i].path),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem {
  const _TabItem(this.path, this.icon, this.label);
  final String path;
  final IconData icon;
  final String label;
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  final List<_TabItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.palette.isDark;
    return ClipRRect(
      borderRadius: AppRadius.xlR,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: context.palette.surfaceGlassElevated,
            border: Border.all(
              color: context.palette.surfaceBorder,
              width: 1,
            ),
            borderRadius: AppRadius.xlR,
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? AppColors.glowViolet
                    : const Color(0x1F000000),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < tabs.length; i++)
                _TabButton(
                  item: tabs[i],
                  selected: i == currentIndex,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _TabItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? context.palette.textPrimary : context.palette.textTertiary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.xlR,
        child: AnimatedContainer(
          duration: AppMotion.interactive,
          curve: AppMotion.interactiveCurve,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AppMotion.interactive,
                padding: const EdgeInsets.all(AppSpacing.xs + 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? AppColors.brandViolet.withValues(alpha: 0.3)
                      : Colors.transparent,
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: context.palette.brandShadowSoft,
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(item.icon, size: 22, color: color),
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: AppTypography.label.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
