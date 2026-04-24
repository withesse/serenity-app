import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/aurora_background.dart';
import '../../core/widgets/mood_picker_sheet.dart';
import '../../core/widgets/star_field.dart';
import '../../core/theme/app_colors.dart';
import '../../data/favourites_store.dart';
import '../../l10n/app_localizations.dart';
import '../library/library_data.dart';
import 'player_controller.dart';
import 'widgets/scene_picker.dart';
import 'widgets/timer_ring.dart';
import 'widgets/transport_controls.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  @override
  void initState() {
    super.initState();
    // Defer to post-frame so Localizations is in scope.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(playerProvider.notifier).loadSession(
            widget.sessionId,
            locale: Localizations.localeOf(context),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionId = widget.sessionId;
    final state = ref.watch(playerProvider);
    final ctrl = ref.read(playerProvider.notifier);

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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopBar(
                    onClose: () async {
                      // Prompt mood only when the user actually listened for
                      // at least a minute — closing right away shouldn't pop
                      // a check-in.
                      if (state.position.inSeconds >= 60) {
                        await showMoodPickerSheet(
                          context,
                          sessionId: sessionId,
                        );
                      }
                      if (context.mounted) context.pop();
                    },
                    sessionId: sessionId,
                  ),
                  const Spacer(flex: 1),
                  Center(
                    child: TimerRing(
                      progress: state.progress,
                      position: state.position,
                      duration: state.duration,
                      breathing: state.isPlaying,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    state.title,
                    style: AppTypography.headline,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    state.subtitle,
                    style: AppTypography.bodyMd,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    state.narrator,
                    style: AppTypography.label.copyWith(
                      color: context.palette.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 2),
                  TransportControls(
                    isPlaying: state.isPlaying,
                    onTogglePlay: ctrl.togglePlay,
                    onSkipBack: () =>
                        ctrl.skip(const Duration(seconds: -15)),
                    onSkipForward: () =>
                        ctrl.skip(const Duration(seconds: 15)),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _BottomBar(
                    speed: state.speed,
                    scene: state.scene,
                    onSpeedTap: ctrl.cycleSpeed,
                    onScenePick: () async {
                      final picked = await showScenePicker(
                        context,
                        current: state.scene,
                      );
                      if (picked != null) ctrl.setScene(picked);
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.onClose, required this.sessionId});
  final VoidCallback onClose;
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favourited = ref.watch(
      favouritesProvider.select((s) => s.contains(sessionId)),
    );
    final category = ref.watch(playerProvider.select((s) => s.category));
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          _CircleIconButton(icon: LucideIcons.x, onTap: onClose),
          const Spacer(),
          if (category != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs + 2,
              ),
              decoration: BoxDecoration(
                borderRadius: AppRadius.pillR,
                color: context.palette.surfaceGlass,
                border: Border.all(color: context.palette.surfaceBorder),
              ),
              child: Text(
                category.labelLocalized(L10n.of(context)),
                style: AppTypography.label,
              ),
            )
          else
            const SizedBox.shrink(),
          const Spacer(),
          _CircleIconButton(
            icon: favourited ? Icons.favorite : Icons.favorite_border,
            iconColor: favourited ? AppColors.brandGold : null,
            onTap: () =>
                ref.read(favouritesProvider.notifier).toggle(sessionId),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.speed,
    required this.scene,
    required this.onSpeedTap,
    required this.onScenePick,
  });
  final double speed;
  final BackgroundScene scene;
  final VoidCallback onSpeedTap;
  final VoidCallback onScenePick;

  @override
  Widget build(BuildContext context) {
    final speedLabel =
        speed == speed.truncateToDouble() ? '${speed.toInt()}x' : '${speed}x';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _PillAction(
          icon: sceneIcon(scene),
          label: sceneLabel(scene, L10n.of(context)),
          onTap: onScenePick,
        ),
        _PillAction(
          icon: LucideIcons.gauge,
          label: speedLabel,
          onTap: onSpeedTap,
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.surfaceGlass,
      shape: CircleBorder(
        side: BorderSide(color: context.palette.surfaceBorder, width: 1),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            size: 20,
            color: iconColor ?? context.palette.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _PillAction extends StatelessWidget {
  const _PillAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.surfaceGlass,
      borderRadius: AppRadius.pillR,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pillR,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.pillR,
            border: Border.all(color: context.palette.surfaceBorder, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: context.palette.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.label
                    .copyWith(color: context.palette.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
