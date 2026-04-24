import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/downloads_store.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Glass-style pill that flips through the download lifecycle for one
/// session: `Download` → `48%` (with cancel) → `Downloaded` (with tap-to-
/// remove). Hosts its own progress ring so callers just pass a session id.
class DownloadButton extends ConsumerWidget {
  const DownloadButton({super.key, required this.sessionId});
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(downloadEntryProvider(sessionId));
    final l = L10n.of(context);
    final palette = context.palette;

    final (String label, IconData icon, VoidCallback onTap, Color tint) =
        switch (entry.status) {
      DownloadStatus.completed => (
          l.downloadRemove,
          LucideIcons.checkCircle,
          () => ref.read(downloadsProvider.notifier).remove(sessionId),
          AppColors.brandGold,
        ),
      DownloadStatus.downloading || DownloadStatus.queued => (
          '${(entry.progress * 100).round()}%',
          LucideIcons.x,
          () => ref.read(downloadsProvider.notifier).cancel(sessionId),
          palette.textPrimary,
        ),
      _ => (
          l.downloadStart,
          LucideIcons.download,
          () => ref.read(downloadsProvider.notifier).start(sessionId),
          palette.textPrimary,
        ),
    };

    return Material(
      color: palette.surfaceGlass,
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
            border: Border.all(color: palette.surfaceBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: entry.isActive
                    ? CircularProgressIndicator(
                        value: entry.progress == 0 ? null : entry.progress,
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation(AppColors.brandVioletLight),
                      )
                    : Icon(icon, size: 16, color: tint),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.label.copyWith(color: tint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
