import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/haptics.dart';
import '../theme/app_palette.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Secondary CTA. Transparent glass surface with 1px border.
class GhostButton extends ConsumerWidget {
  const GhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = onPressed != null;
    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.5,
      duration: AppMotion.interactive,
      child: Material(
        color: context.palette.surfaceGlass,
        borderRadius: AppRadius.pillR,
        child: InkWell(
          onTap: enabled
              ? () {
                  ref.read(hapticsProvider).selection();
                  onPressed!();
                }
              : null,
          borderRadius: AppRadius.pillR,
          child: Container(
            height: 56,
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            decoration: BoxDecoration(
              borderRadius: AppRadius.pillR,
              border: Border.all(
                color: context.palette.surfaceBorderStrong,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: context.palette.textPrimary),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  label,
                  style: AppTypography.title.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
