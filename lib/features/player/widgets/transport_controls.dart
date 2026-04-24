import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/haptics.dart';
import '../../../l10n/app_localizations.dart';

class TransportControls extends StatelessWidget {
  const TransportControls({
    super.key,
    required this.isPlaying,
    required this.onTogglePlay,
    required this.onSkipBack,
    required this.onSkipForward,
  });

  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final VoidCallback onSkipBack;
  final VoidCallback onSkipForward;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _SkipButton(
          icon: LucideIcons.rotateCcw,
          label: '15',
          semanticsLabel: l.playerSkipBack15,
          onTap: onSkipBack,
        ),
        _PlayButton(
          isPlaying: isPlaying,
          onTap: onTogglePlay,
          semanticsLabel: isPlaying ? l.playerPause : l.playerPlay,
        ),
        _SkipButton(
          icon: LucideIcons.rotateCw,
          label: '15',
          semanticsLabel: l.playerSkipForward15,
          onTap: onSkipForward,
        ),
      ],
    );
  }
}

class _PlayButton extends ConsumerWidget {
  const _PlayButton({
    required this.isPlaying,
    required this.onTap,
    required this.semanticsLabel,
  });

  final bool isPlaying;
  final VoidCallback onTap;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.palette.isDark;
    // On dawn the full-saturation brand gradient punches through the cream
    // sky too aggressively for what's essentially a meditation trigger.
    // Lerp each stop ~30% toward white so the button stays brand-coloured
    // but reads as a soft lavender-dawn pill instead of a neon puck.
    final gradientColors = isDark
        ? AppColors.violetAuroraGradient
        : const [Color(0xFFB3AAE8), Color(0xFF9BA4E5)];
    final iconColor =
        isDark ? context.palette.textPrimary : const Color(0xFFFFFFFF);
    return Tooltip(
      message: semanticsLabel,
      child: Semantics(
        button: true,
        label: semanticsLabel,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: context.palette.brandShadow,
                blurRadius: 36,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                ref.read(hapticsProvider).medium();
                onTap();
              },
              child: SizedBox(
                width: 84,
                height: 84,
                child: AnimatedSwitcher(
                  duration: AppMotion.interactive,
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isPlaying ? LucideIcons.pause : LucideIcons.play,
                    key: ValueKey(isPlaying),
                    size: 32,
                    color: iconColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkipButton extends ConsumerWidget {
  const _SkipButton({
    required this.icon,
    required this.label,
    required this.semanticsLabel,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: semanticsLabel,
      child: Semantics(
        button: true,
        label: semanticsLabel,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              ref.read(hapticsProvider).selection();
              onTap();
            },
            child: Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, size: 44, color: context.palette.textSecondary),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs + 2),
                    child: Text(
                      label,
                      style: AppTypography.label.copyWith(
                        color: context.palette.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
