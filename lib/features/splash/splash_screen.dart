import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/aurora_background.dart';
import '../../core/widgets/star_field.dart';
import '../../data/profile_store.dart';
import '../../l10n/app_localizations.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();

  @override
  void initState() {
    super.initState();
    // Returning users skip onboarding; the questionnaire sets `onboarded`
    // once completed (or skipped).
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      final onboarded = ref.read(profileProvider).onboarded;
      context.go(onboarded ? '/home' : '/onboarding');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuroraBackground(
      child: Stack(
        children: [
          const Positioned.fill(child: StarField(density: StarDensity.dense)),
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _controller,
                    curve: AppMotion.pageCurve,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: AppColors.violetAuroraGradient,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: context.palette.brandShadow,
                              blurRadius: 48,
                            ),
                          ],
                        ),
                        child: Icon(
                          LucideIcons.moon,
                          size: 40,
                          color: context.palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(L10n.of(context).appName,
                          style: AppTypography.displayLg),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        L10n.of(context).appTagline,
                        style: AppTypography.bodyMd.copyWith(
                          color: context.palette.textTertiary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
