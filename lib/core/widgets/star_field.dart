import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

enum StarDensity { sparse, normal, dense }

/// Twinkling-point star layer. Composed above [AuroraBackground] and below
/// content. Uses a single ticker driving opacity on a deterministic star set
/// seeded by [seed] so stars never jump between builds.
class StarField extends StatefulWidget {
  const StarField({
    super.key,
    this.density = StarDensity.normal,
    this.seed = 42,
  });

  final StarDensity density;
  final int seed;

  @override
  State<StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<StarField>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // Non-lazy — a `late final` with a Ticker would only be constructed when
  // first accessed inside build(), and in dawn mode build() returns
  // SizedBox.shrink() and never touches it. dispose() would then lazily
  // construct the controller and immediately fail (Ticker needs an active
  // element for `dependOnInheritedWidgetOfExactType`).
  late final AnimationController _controller;
  late final List<_Star> _stars = _generate();

  List<_Star> _generate() {
    final rng = math.Random(widget.seed);
    final count = switch (widget.density) {
      StarDensity.sparse => 40,
      StarDensity.normal => 80,
      StarDensity.dense => 140,
    };
    return List.generate(count, (_) {
      return _Star(
        position: Offset(rng.nextDouble(), rng.nextDouble()),
        radius: 0.4 + rng.nextDouble() * 1.4,
        phase: rng.nextDouble(),
        speed: 0.5 + rng.nextDouble() * 1.5,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dawn sky: stars have faded. Skip the layer entirely — both honours the
    // metaphor ("first light") and saves a repaint every 6s.
    if (!context.palette.isDark) {
      return const SizedBox.shrink();
    }

    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final starColor = context.palette.textPrimary;
    // RepaintBoundary pins every-frame repaints to the star layer so the
    // rest of the aurora/child tree doesn't re-rasterise at 60Hz. Single
    // biggest perf win on Android.
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: IgnorePointer(
          child: reduceMotion
              ? CustomPaint(painter: _StarPainter(_stars, 0, starColor))
              : AnimatedBuilder(
                  animation: _controller,
                  builder: (_, _) => CustomPaint(
                    painter:
                        _StarPainter(_stars, _controller.value, starColor),
                    size: Size.infinite,
                  ),
                ),
        ),
      ),
    );
  }
}

class _Star {
  _Star({
    required this.position,
    required this.radius,
    required this.phase,
    required this.speed,
  });

  /// Normalised 0..1 position.
  final Offset position;
  final double radius;
  final double phase;
  final double speed;
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.stars, this.t, this.color);
  final List<_Star> stars;
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // One Paint reused across all stars. Per-frame allocation of N Paint
    // objects was producing several KB of GC pressure per second on
    // dense mode. MaskFilter.blur is gone too — it was paying a full-screen
    // CPU blur pass for a 0.6px halo nobody could see on a HiDPI display.
    final paint = Paint();
    for (final star in stars) {
      final phase = (t * star.speed + star.phase) % 1;
      final twinkle = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(phase * 2 * math.pi));
      paint.color = color.withValues(alpha: 0.55 * twinkle);
      canvas.drawCircle(
        Offset(star.position.dx * size.width, star.position.dy * size.height),
        star.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color;
}
