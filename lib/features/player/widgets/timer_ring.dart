import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_typography.dart';

/// Circular timer with breathing aura. The outer stroke shows track progress
/// (violet→gold gradient, rounded caps). The inner aura pulses on a 4-second
/// sine loop when [breathing] is true (i.e. playback is active).
String _fmtTimerDuration(Duration d) {
  // Clamp tiny negatives (rounding at the very end of a track) to 0:00 so
  // the countdown doesn't flash "-0:00" between the last audio frame and
  // the completion event.
  if (d.isNegative) d = Duration.zero;
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

Duration _remaining(Duration position, Duration duration) {
  final remaining = duration - position;
  return remaining.isNegative ? Duration.zero : remaining;
}

@visibleForTesting
String timerRingSemanticsLabel(Duration position, Duration duration) {
  final totalMs = duration.inMilliseconds;
  final percent = totalMs <= 0
      ? 0
      : ((position.inMilliseconds / totalMs) * 100).clamp(0, 100).round();
  return '${_fmtTimerDuration(_remaining(position, duration))} remaining '
      'of ${_fmtTimerDuration(duration)}, $percent% complete';
}

class TimerRing extends StatefulWidget {
  const TimerRing({
    super.key,
    required this.progress,
    required this.position,
    required this.duration,
    required this.breathing,
    this.size = 280,
  });

  final double progress; // 0..1
  final Duration position;
  final Duration duration;
  final bool breathing;
  final double size;

  @override
  State<TimerRing> createState() => _TimerRingState();
}

class _TimerRingState extends State<TimerRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.breathing,
  );

  @override
  void initState() {
    super.initState();
    _updateAnim();
  }

  @override
  void didUpdateWidget(covariant TimerRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.breathing != widget.breathing) _updateAnim();
  }

  void _updateAnim() {
    if (widget.breathing) {
      _controller.repeat(reverse: true);
    } else {
      _controller.animateTo(0.5, duration: AppMotion.pageTransition);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Semantics(
      container: true,
      // Deliberately NOT a live region — position updates fire ~every frame
      // of playback, which would cause VoiceOver / TalkBack to announce
      // the countdown continuously. The label still reflects current
      // state, so a user can re-focus the ring to hear "X:XX remaining"
      // on demand.
      label: timerRingSemanticsLabel(widget.position, widget.duration),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (reduceMotion)
              _Aura(breath: 0.5, size: widget.size)
            else
              AnimatedBuilder(
                animation: _controller,
                builder: (_, _) => _Aura(
                  breath: Curves.easeInOutSine.transform(_controller.value),
                  size: widget.size,
                ),
              ),
            CustomPaint(
              size: Size.square(widget.size),
              painter: _RingPainter(
                widget.progress,
                context.palette.textPrimary,
              ),
            ),
            _TimerText(position: widget.position, duration: widget.duration),
          ],
        ),
      ),
    );
  }
}

class _Aura extends StatelessWidget {
  const _Aura({required this.breath, required this.size});
  final double breath; // 0..1
  final double size;

  @override
  Widget build(BuildContext context) {
    // Two stacked auras: an outer ambient wash + an inner focused core that
    // breathes more noticeably. Together they read as a warm glow centred
    // inside the progress ring without ever eclipsing the timer digits.
    final outerScale = 0.85 + 0.22 * breath;
    final innerScale = 0.48 + 0.18 * breath;
    final outerOpacity = 0.18 + 0.28 * breath;
    final innerOpacity = 0.32 + 0.42 * breath;

    return IgnorePointer(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: outerScale,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.brandVioletLight.withValues(alpha: outerOpacity),
                    AppColors.brandViolet
                        .withValues(alpha: outerOpacity * 0.35),
                    AppColors.brandViolet.withValues(alpha: 0),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          Transform.scale(
            scale: innerScale,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.auroraMid.withValues(alpha: innerOpacity),
                    AppColors.brandViolet
                        .withValues(alpha: innerOpacity * 0.4),
                    AppColors.brandViolet.withValues(alpha: 0),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress, this.trackColor);
  final double progress;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = trackColor.withValues(alpha: 0.12);
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;

    // Progress arc — violet→gold sweep, rounded end cap
    final sweep = progress * 2 * math.pi;
    final startAngle = -math.pi / 2;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        transform: const GradientRotation(-math.pi / 2),
        colors: const [
          AppColors.brandViolet,
          AppColors.brandVioletLight,
          AppColors.brandGold,
        ],
        stops: const [0, 0.7, 1],
      ).createShader(rect);

    canvas.drawArc(rect, startAngle, sweep, false, progressPaint);

    // Gold tick at current position
    final tickAngle = startAngle + sweep;
    final tickPos = Offset(
      center.dx + radius * math.cos(tickAngle),
      center.dy + radius * math.sin(tickAngle),
    );
    final tickGlow = Paint()
      ..color = AppColors.brandGold.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(tickPos, 8, tickGlow);
    final tickCore = Paint()..color = AppColors.brandGold;
    canvas.drawCircle(tickPos, 4, tickCore);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.trackColor != trackColor;
}

class _TimerText extends StatelessWidget {
  const _TimerText({required this.position, required this.duration});
  final Duration position;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    // Big number counts DOWN — the more useful "how much longer do I sit"
    // reading for a meditation session. Total stays below as context.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _fmtTimerDuration(_remaining(position, duration)),
          style: AppTypography.timer,
        ),
        const SizedBox(height: 4),
        Text(
          _fmtTimerDuration(duration),
          style: AppTypography.duration.copyWith(
            color: context.palette.textTertiary,
          ),
        ),
      ],
    );
  }
}
