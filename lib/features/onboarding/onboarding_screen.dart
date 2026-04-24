import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/aurora_background.dart';
import '../../core/widgets/ghost_button.dart';
import '../../core/widgets/pill_button.dart';
import '../../core/widgets/star_field.dart';
import '../../l10n/app_localizations.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return AuroraBackground(
      child: Stack(
        children: [
          const Positioned.fill(child: StarField()),
          SafeArea(
            child: Padding(
              padding: AppSpacing.screenHorizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Text(
                    l.onboardingTitle,
                    style: AppTypography.displayLg,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l.onboardingSubtitle,
                    style: AppTypography.bodyLg,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  PillButton(
                    key: const Key('onboarding-begin'),
                    label: l.onboardingBegin,
                    onPressed: () => context.go('/onboarding/goals'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GhostButton(
                    label: l.onboardingHaveAccount,
                    onPressed: () => context.go('/auth'),
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
