import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';

enum BackgroundScene { off, rain, forest, waves, fire, night }

String sceneLabel(BackgroundScene s, L10n l) => switch (s) {
      BackgroundScene.off => l.sceneLabelOff,
      BackgroundScene.rain => l.sceneLabelRain,
      BackgroundScene.forest => l.sceneLabelForest,
      BackgroundScene.waves => l.sceneLabelWaves,
      BackgroundScene.fire => l.sceneLabelFire,
      BackgroundScene.night => l.sceneLabelNight,
    };

IconData sceneIcon(BackgroundScene s) => switch (s) {
      BackgroundScene.off => LucideIcons.mic,
      BackgroundScene.rain => LucideIcons.cloudRain,
      BackgroundScene.forest => LucideIcons.trees,
      BackgroundScene.waves => LucideIcons.waves,
      BackgroundScene.fire => LucideIcons.flame,
      BackgroundScene.night => LucideIcons.moon,
    };

Future<BackgroundScene?> showScenePicker(
  BuildContext context, {
  required BackgroundScene current,
}) {
  return showModalBottomSheet<BackgroundScene>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _ScenePicker(current: current),
  );
}

class _ScenePicker extends StatelessWidget {
  const _ScenePicker({required this.current});
  final BackgroundScene current;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return Container(
      decoration: BoxDecoration(
        color: context.palette.bgMid,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        border: Border(top: BorderSide(color: context.palette.surfaceBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: context.palette.surfaceBorderStrong,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(l.scenePickerTitle, style: AppTypography.title),
            ),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.1,
              children: [
                for (final s in BackgroundScene.values)
                  _SceneTile(
                    scene: s,
                    selected: s == current,
                    onTap: () => Navigator.of(context).pop(s),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SceneTile extends StatelessWidget {
  const _SceneTile({
    required this.scene,
    required this.selected,
    required this.onTap,
  });

  final BackgroundScene scene;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: sceneLabel(scene, L10n.of(context)),
      child: Material(
        color: selected
            ? AppColors.brandViolet.withValues(alpha: 0.3)
            : context.palette.surfaceGlass,
        borderRadius: AppRadius.mdR,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdR,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdR,
              border: Border.all(
                color: selected
                    ? AppColors.brandVioletLight
                    : context.palette.surfaceBorder,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: context.palette.brandShadowSoft,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  sceneIcon(scene),
                  size: 26,
                  color: selected
                      ? context.palette.textPrimary
                      : context.palette.textSecondary,
                ),
                const SizedBox(height: 6),
                Text(
                  sceneLabel(scene, L10n.of(context)),
                  style: AppTypography.label.copyWith(
                    color: selected
                        ? context.palette.textPrimary
                        : context.palette.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
