import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/haptics.dart';
import '../../data/mood_store.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 1..5 scale, worst → best. Kept as ints in storage so they're trivially
/// ordered and plottable. Emojis render with the platform font and match
/// the muted palette so they don't overpower the glass surface.
const _moods = <(int, String)>[
  (1, '😔'),
  (2, '😐'),
  (3, '🙂'),
  (4, '😌'),
  (5, '✨'),
];

/// Shows the post-session mood check-in. Returns the recorded score, or null
/// if the user dismissed without picking. Persists through [moodProvider]
/// when a score is chosen.
Future<int?> showMoodPickerSheet(
  BuildContext context, {
  String? sessionId,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (_) => _MoodPickerSheet(sessionId: sessionId),
  );
}

class _MoodPickerSheet extends ConsumerWidget {
  const _MoodPickerSheet({this.sessionId});
  final String? sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L10n.of(context);
    final palette = context.palette;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Container(
          decoration: BoxDecoration(
            color: palette.isDark
                ? const Color(0xFF1A1B3A)
                : const Color(0xFFF5F2EC),
            borderRadius: AppRadius.lgR,
            border: Border.all(color: palette.surfaceBorder),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.moodSheetTitle, style: AppTypography.headline),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l.moodSheetSubtitle,
                style: AppTypography.bodyMd.copyWith(
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final (score, emoji) in _moods)
                    _MoodChip(
                      emoji: emoji,
                      label: _labelFor(score, l),
                      onTap: () async {
                        await ref.read(hapticsProvider).selection();
                        await ref
                            .read(moodProvider.notifier)
                            .record(score, sessionId: sessionId);
                        if (context.mounted) Navigator.of(context).pop(score);
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l.moodSheetSkip),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _labelFor(int score, L10n l) => switch (score) {
        1 => l.moodLabel1,
        2 => l.moodLabel2,
        3 => l.moodLabel3,
        4 => l.moodLabel4,
        _ => l.moodLabel5,
      };
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdR,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.label.copyWith(
                color: context.palette.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
