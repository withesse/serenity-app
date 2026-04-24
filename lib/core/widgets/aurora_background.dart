import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_motion.dart';

/// Full-screen night-sky backdrop used as the root of every route.
///
/// Three layers:
///   1. Vertical gradient (bgTop → bgMid → bgDeep)
///   2. Slowly drifting radial nebula (violet + pink)
///   3. Child content on top
///
/// [StarField] is a separate widget composed on top when wanted.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({
    super.key,
    required this.child,
    this.enableNebula = true,
  });

  final Widget child;
  final bool enableNebula;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // See _StarFieldState: non-lazy to avoid lazy-init during dispose.
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.auroraDrift,
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
    // Pause the nebula drift when the user backgrounds the app — that shader
    // is cheap but infinite, and letting it run while we're unfocused drains
    // battery for no benefit. Resume on return.
    if (state == AppLifecycleState.resumed) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final palette = context.palette;

    // Scaffold provides the Material + DefaultTextStyle ancestors so that
    // Text widgets below don't fall through to the yellow double-underline
    // default. scaffoldBackgroundColor is already bgDeep, but we overlay the
    // full aurora gradient on top so the visual is the rich night sky.
    //
    // The violet/pink nebula only makes sense at night — in dawn mode we
    // trust the sky-gradient alone to carry the atmosphere.
    final showNebula = widget.enableNebula && palette.isDark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: palette.bgDeep,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 0.5, 1],
            colors: palette.skyGradient,
          ),
        ),
        child: Stack(
          children: [
            if (showNebula)
              Positioned.fill(
                // RepaintBoundary isolates the nebula's 60Hz repaint from
                // the rest of the subtree — without it every static tile
                // re-rasterises each frame on Android.
                child: ExcludeSemantics(
                  child: RepaintBoundary(
                    child: reduceMotion
                        ? const _NebulaPainterHost(progress: 0.2)
                        : AnimatedBuilder(
                            animation: _controller,
                            builder: (_, _) => _NebulaPainterHost(
                              progress: _controller.value,
                            ),
                          ),
                  ),
                ),
              ),
            Positioned.fill(child: widget.child),
          ],
        ),
      ),
    );
  }
}

class _NebulaPainterHost extends StatelessWidget {
  const _NebulaPainterHost({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _NebulaPainter(progress));
}

class _NebulaPainter extends CustomPainter {
  _NebulaPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2 * math.pi;

    // Violet nebula (upper right drifting)
    final violetCenter = Offset(
      size.width * (0.7 + 0.05 * math.sin(t)),
      size.height * (0.25 + 0.03 * math.cos(t)),
    );
    _drawNebula(
      canvas,
      size,
      violetCenter,
      AppColors.brandViolet.withValues(alpha: 0.35),
      radius: size.width * 0.8,
    );

    // Aurora-end pink glow (lower left, slower)
    final pinkCenter = Offset(
      size.width * (0.2 + 0.04 * math.cos(t * 0.5)),
      size.height * (0.75 + 0.04 * math.sin(t * 0.5)),
    );
    _drawNebula(
      canvas,
      size,
      pinkCenter,
      AppColors.auroraEnd.withValues(alpha: 0.18),
      radius: size.width * 0.7,
    );
  }

  // Reused across paint() calls to skip the `drawRect` full-screen pass per
  // nebula layer — drawCircle+clipRect on the affected region only. The
  // RadialGradient shader is still rebuilt each frame because the center
  // moves, but the surface area being covered is far smaller.
  void _drawNebula(
    Canvas canvas,
    Size size,
    Offset center,
    Color color, {
    required double radius,
  }) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(rect);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _NebulaPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
