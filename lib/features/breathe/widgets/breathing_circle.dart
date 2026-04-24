import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../breathing_techniques.dart';

String _phaseLabel(BreathPhase? phase, L10n l) =>
    phase?.labelLocalized(l) ?? l.breatheReady;

String _phaseSemanticsLabel(BreathPhase? phase, int phaseSecondsLeft, L10n l) {
  if (phase == null) return l.breatheReadyToBegin;
  return l.breatheSemanticsSecondsLeft(
    phase.labelLocalized(l),
    phaseSecondsLeft,
  );
}

/// Concentric breathing visualizer. Three nested glass rings scale together
/// based on [scale] (0..1 → 0.5..1.0 radius). The centre holds the phase
/// label + remaining-seconds countdown.
class BreathingCircle extends StatelessWidget {
  const BreathingCircle({
    super.key,
    required this.scale,
    required this.phase,
    required this.phaseSecondsLeft,
    required this.size,
  });

  final double scale; // 0..1
  final BreathPhase? phase;
  final int phaseSecondsLeft;
  final double size;

  double get _radius => size * (0.55 + 0.45 * scale);

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return Semantics(
      container: true,
      liveRegion: true,
      label: _phaseSemanticsLabel(phase, phaseSecondsLeft, l),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _Ring(radius: _radius, opacity: 0.04, blurRadius: 60),
            _Ring(radius: _radius * 0.82, opacity: 0.08, blurRadius: 40),
            _Ring(
              radius: _radius * 0.64,
              opacity: 0.18,
              blurRadius: 24,
              solidCore: true,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: Text(
                    _phaseLabel(phase, l),
                    key: ValueKey(phase),
                    style: AppTypography.headline.copyWith(
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$phaseSecondsLeft',
                  style: AppTypography.timer.copyWith(fontSize: 72),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({
    required this.radius,
    required this.opacity,
    required this.blurRadius,
    this.solidCore = false,
  });

  final double radius;
  final double opacity;
  final double blurRadius;
  final bool solidCore;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutSine,
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.brandVioletLight.withValues(alpha: opacity),
        gradient: solidCore
            ? RadialGradient(
                colors: [
                  AppColors.brandVioletLight.withValues(alpha: opacity * 2),
                  AppColors.brandViolet.withValues(alpha: opacity * 0.4),
                  AppColors.brandViolet.withValues(alpha: 0),
                ],
                stops: const [0.0, 0.6, 1.0],
              )
            : null,
        border: Border.all(
          color: context.palette.surfaceBorder,
          width: solidCore ? 1 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandViolet.withValues(alpha: opacity * 1.5),
            blurRadius: blurRadius,
            spreadRadius: blurRadius / 4,
          ),
        ],
      ),
    );
  }
}
