import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/aurora_background.dart';
import '../../core/widgets/mood_picker_sheet.dart';
import '../../core/widgets/star_field.dart';
import '../../data/analytics.dart';
import '../../data/haptics.dart';
import '../../l10n/app_localizations.dart';
import 'breathing_techniques.dart';
import 'widgets/breathing_circle.dart';

class BreatheSessionScreen extends ConsumerStatefulWidget {
  const BreatheSessionScreen({super.key, this.techniqueId});

  final String? techniqueId;

  @override
  ConsumerState<BreatheSessionScreen> createState() =>
      _BreatheSessionScreenState();
}

class _BreatheSessionScreenState extends ConsumerState<BreatheSessionScreen>
    with SingleTickerProviderStateMixin {
  late final BreathingTechnique _technique;
  late AnimationController _phaseController;
  Timer? _tick;
  int _stepIndex = 0;
  int _roundsCompleted = 0;
  int _secondsInPhase = 0;
  bool _running = false;
  bool _finished = false;

  BreathStep get _step => _technique.steps[_stepIndex];

  @override
  void initState() {
    super.initState();
    _technique = breathingTechniques.firstWhere(
      (t) => t.id == widget.techniqueId,
      orElse: () => breathingTechniques.first,
    );
    _phaseController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _step.seconds),
    );
  }

  @override
  void dispose() {
    _tick?.cancel();
    _phaseController.dispose();
    super.dispose();
  }

  void _start() {
    if (_running || _finished) return;
    final firstStart = _roundsCompleted == 0 && _stepIndex == 0;
    setState(() => _running = true);
    _beginPhase();
    if (firstStart) {
      ref.read(analyticsProvider).track(
        AnalyticsEvents.breathingStarted,
        {'techniqueId': _technique.id},
      );
    }
  }

  void _pause() {
    _tick?.cancel();
    _phaseController.stop();
    setState(() => _running = false);
  }

  void _beginPhase() {
    _phaseController
      ..duration = Duration(seconds: _step.seconds)
      ..reset();
    if (_stepScaleGoesUp) {
      _phaseController.forward();
    } else if (_stepScaleGoesDown) {
      _phaseController.reverse(from: 1);
    } else {
      // hold — controller value stays; we only use the tick timer.
      _phaseController.value = _stepHoldValue;
    }
    _secondsInPhase = _step.seconds;
    ref.read(hapticsProvider).selection();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _secondsInPhase--;
      });
      if (_secondsInPhase <= 0) _advance();
    });
    setState(() {});
  }

  void _advance() {
    _tick?.cancel();
    if (_stepIndex < _technique.steps.length - 1) {
      _stepIndex++;
    } else {
      _stepIndex = 0;
      _roundsCompleted++;
      if (_roundsCompleted >= _technique.rounds) {
        _finish();
        return;
      }
    }
    _beginPhase();
  }

  void _finish() {
    _tick?.cancel();
    _phaseController.stop();
    ref.read(hapticsProvider).medium();
    ref.read(analyticsProvider).track(
      AnalyticsEvents.breathingCompleted,
      {'techniqueId': _technique.id, 'rounds': _technique.rounds},
    );
    setState(() {
      _running = false;
      _finished = true;
    });
    // Wait one frame so the "Complete." message paints before the sheet
    // slides up; otherwise the transition feels abrupt.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showMoodPickerSheet(context, sessionId: _technique.id);
    });
  }

  bool get _stepScaleGoesUp => _step.phase == BreathPhase.inhale;
  bool get _stepScaleGoesDown => _step.phase == BreathPhase.exhale;
  double get _stepHoldValue =>
      _step.phase == BreathPhase.holdFull ? 1.0 : 0.0;

  @override
  Widget build(BuildContext context) {
    final localizedTechnique = _technique.localized(Localizations.localeOf(context));
    return AuroraBackground(
      child: Stack(
        children: [
          const Positioned.fill(
            child: StarField(density: StarDensity.dense),
          ),
          SafeArea(
            child: Padding(
              padding: AppSpacing.screenHorizontal,
              child: Column(
                children: [
                  _Header(
                    name: localizedTechnique.name,
                    round: _roundsCompleted + 1,
                    totalRounds: _technique.rounds,
                    onClose: () => context.pop(),
                  ),
                  const Spacer(flex: 1),
                  AnimatedBuilder(
                    animation: _phaseController,
                    builder: (_, _) => BreathingCircle(
                      scale: _phaseController.value,
                      phase: _running || _finished ? _step.phase : null,
                      phaseSecondsLeft: _finished
                          ? 0
                          : _running
                              ? _secondsInPhase
                              : _step.seconds,
                      size: 300,
                    ),
                  ),
                  const Spacer(flex: 2),
                  if (_finished)
                    _FinishedMessage(
                      onRestart: () {
                        setState(() {
                          _finished = false;
                          _stepIndex = 0;
                          _roundsCompleted = 0;
                        });
                        _start();
                      },
                    )
                  else
                    _StartPauseButton(
                      running: _running,
                      onTap: _running ? _pause : _start,
                    ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.round,
    required this.totalRounds,
    required this.onClose,
  });

  final String name;
  final int round;
  final int totalRounds;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
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
                child: Icon(LucideIcons.x, size: 20),
              ),
            ),
          ),
          const Spacer(),
          Column(
            children: [
              Text(name, style: AppTypography.title),
              const SizedBox(height: 2),
              Text(
                L10n.of(context)
                    .breatheRound(round, totalRounds),
                style: AppTypography.label
                    .copyWith(color: context.palette.textTertiary),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _StartPauseButton extends ConsumerWidget {
  const _StartPauseButton({required this.running, required this.onTap});
  final bool running;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.palette.isDark;
    final gradientColors = isDark
        ? AppColors.violetAuroraGradient
        : const [Color(0xFFB3AAE8), Color(0xFF9BA4E5)];
    final iconColor =
        isDark ? context.palette.textPrimary : const Color(0xFFFFFFFF);
    return DecoratedBox(
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
            blurRadius: 28,
            offset: const Offset(0, 10),
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
            width: 76,
            height: 76,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                running ? LucideIcons.pause : LucideIcons.play,
                key: ValueKey(running),
                size: 28,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FinishedMessage extends StatelessWidget {
  const _FinishedMessage({required this.onRestart});
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return Column(
      children: [
        Text(l.breatheComplete, style: AppTypography.headline),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l.breatheCompleteSubtitle,
          style: AppTypography.bodyMd,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        TextButton(
          onPressed: onRestart,
          child: Text(l.breatheAgain),
        ),
      ],
    );
  }
}
