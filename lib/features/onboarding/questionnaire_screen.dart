import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/aurora_background.dart';
import '../../core/widgets/ghost_button.dart';
import '../../core/widgets/pill_button.dart';
import '../../core/widgets/star_field.dart';
import '../../data/profile_store.dart';
import '../../l10n/app_localizations.dart';
import '../library/library_data.dart';
import '../profile/medical_disclaimer_dialog.dart';

/// Second step of onboarding — a single-page multi-select. Soundscapes is
/// excluded from the options because it's a format, not a goal; it's still
/// available from the library.
class OnboardingQuestionnaireScreen extends ConsumerStatefulWidget {
  const OnboardingQuestionnaireScreen({super.key});

  @override
  ConsumerState<OnboardingQuestionnaireScreen> createState() =>
      _OnboardingQuestionnaireScreenState();
}

class _OnboardingQuestionnaireScreenState
    extends ConsumerState<OnboardingQuestionnaireScreen> {
  final Set<LibraryCategory> _picked = {};

  static const _options = <LibraryCategory>[
    LibraryCategory.sleep,
    LibraryCategory.focus,
    LibraryCategory.stress,
    LibraryCategory.morning,
  ];

  Future<void> _finish({required bool saveGoals}) async {
    if (saveGoals) {
      await ref.read(profileProvider.notifier).setGoals(_picked);
    }
    await ref.read(profileProvider.notifier).markOnboarded();
    if (!ref.read(profileProvider).medicalDisclaimerAcknowledged) {
      if (!mounted) return;
      final acknowledged = await showMedicalDisclaimerDialog(
        context,
        requireAcknowledgement: true,
      );
      if (acknowledged != true) return;
      await ref
          .read(profileProvider.notifier)
          .acknowledgeMedicalDisclaimer();
    }
    if (!mounted) return;
    context.go('/home');
  }

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
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    l.onboardingGoalsTitle,
                    style: AppTypography.displayMd,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l.onboardingGoalsSubtitle,
                    style: AppTypography.bodyMd.copyWith(
                      color: context.palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final c in _options)
                            _GoalChip(
                              label: _labelFor(c, l),
                              selected: _picked.contains(c),
                              onTap: () {
                                setState(() {
                                  if (!_picked.add(c)) _picked.remove(c);
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  PillButton(
                    label: l.onboardingGoalsContinue,
                    onPressed: _picked.isEmpty
                        ? null
                        : () => _finish(saveGoals: true),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GhostButton(
                    key: const Key('onboarding-goals-skip'),
                    label: l.onboardingGoalsSkip,
                    onPressed: () => _finish(saveGoals: false),
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

  String _labelFor(LibraryCategory c, L10n l) => switch (c) {
        LibraryCategory.sleep => l.libraryCategorySleep,
        LibraryCategory.focus => l.libraryCategoryFocus,
        LibraryCategory.stress => l.libraryCategoryStress,
        LibraryCategory.morning => l.libraryCategoryMorning,
        LibraryCategory.soundscapes => l.libraryCategorySoundscapes,
        LibraryCategory.all => l.libraryCategoryAll,
      };
}

class _GoalChip extends StatelessWidget {
  const _GoalChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.brandViolet.withValues(alpha: 0.35)
          : context.palette.surfaceGlass,
      borderRadius: AppRadius.pillR,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pillR,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.pillR,
            border: Border.all(
              color: selected
                  ? AppColors.brandVioletLight
                  : context.palette.surfaceBorder,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.bodyMd.copyWith(
              color: selected
                  ? context.palette.textPrimary
                  : context.palette.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
