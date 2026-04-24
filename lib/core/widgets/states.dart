import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Loading placeholder — a calm pulsing dot cluster rather than a spinner.
/// Matches the meditative tone; no sharp motion.
class QuietLoader extends StatefulWidget {
  const QuietLoader({super.key, this.label});
  final String? label;

  @override
  State<QuietLoader> createState() => _QuietLoaderState();
}

class _QuietLoaderState extends State<QuietLoader>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (_, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++) ...[
                  _Dot(phase: (_c.value + i * 0.25) % 1),
                  if (i < 2) const SizedBox(width: 10),
                ],
              ],
            ),
          ),
          if (widget.label != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              widget.label!,
              style: AppTypography.bodyMd
                  .copyWith(color: context.palette.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.phase});
  final double phase;

  @override
  Widget build(BuildContext context) {
    final alpha = 0.3 + 0.7 * (0.5 + 0.5 * _sin(phase));
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.brandVioletLight.withValues(alpha: alpha),
      ),
    );
  }

  static double _sin(double t) {
    // Small inline sine so we don't import dart:math for one call.
    // Fast-approx sine for t in 0..1 → -1..1.
    final x = t * 2 * 3.14159265;
    final x2 = x * x;
    final x3 = x2 * x;
    final x5 = x3 * x2;
    return x - x3 / 6 + x5 / 120;
  }
}

/// Generic empty state — illustration-free, just an icon, title, caption,
/// and an optional action. Used wherever a list or collection is empty.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: context.palette.textTertiary),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTypography.headline,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: AppTypography.bodyMd,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Generic error state — distinct colour treatment so failures never read
/// as empty or loading. `onRetry` is optional; the screen may choose to
/// surface the error silently (e.g. a cached view still works).
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.title,
    this.detail,
    this.onRetry,
  });

  final String title;
  final String? detail;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.cloudOff,
              size: 40,
              color: context.palette.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTypography.headline,
              textAlign: TextAlign.center,
            ),
            if (detail != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                detail!,
                style: AppTypography.bodyMd,
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
