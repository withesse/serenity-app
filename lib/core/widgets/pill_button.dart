import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/haptics.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Primary CTA. Height 56, pill-shaped, violet→aurora gradient fill.
///
/// Breathes subtly — the outer glow expands and contracts on a slow 4s loop
/// when idle. The motion pauses if the user has disabled animations.
class PillButton extends ConsumerStatefulWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  ConsumerState<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends ConsumerState<PillButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.breathing,
  );

  @override
  void initState() {
    super.initState();
    if (widget.onPressed != null) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PillButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasEnabled = oldWidget.onPressed != null;
    final isEnabled = widget.onPressed != null;
    if (wasEnabled != isEnabled) {
      if (isEnabled) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final btn = Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.5,
        duration: AppMotion.interactive,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            final breath = reduceMotion
                ? 0.5
                : Curves.easeInOutSine.transform(_controller.value);
            final glowBlur = 18 + 14 * breath;
            final glowOffset = 8 + 6 * breath;
            final isDark = context.palette.isDark;
            // Dawn: shift the gradient toward soft lavender (keeps the brand
            // identity without pitching a dark brand-blue slab onto the
            // cream sky) and calm the shadow down.
            final colors = isDark
                ? AppColors.violetAuroraGradient
                : const [Color(0xFFB3AAE8), Color(0xFF9BA4E5)];
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: AppRadius.pillR,
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? AppColors.glowVioletStrong
                        : const Color(0x14000000), // black 8%
                    blurRadius: isDark ? glowBlur : glowBlur * 0.6,
                    offset: Offset(0, glowOffset * (isDark ? 1 : 0.6)),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: AppRadius.pillR,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: enabled
                      ? () {
                          ref.read(hapticsProvider).light();
                          widget.onPressed!();
                        }
                      : null,
                  borderRadius: AppRadius.pillR,
                  child: SizedBox(
                    height: 56,
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: ExcludeSemantics(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon,
                        size: 20, color: context.palette.textPrimary),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    widget.label,
                    style: AppTypography.title.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return widget.expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
