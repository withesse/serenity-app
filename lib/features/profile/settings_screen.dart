import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/analytics.dart';
import '../../data/auth_store.dart';
import '../../data/crash_reporter.dart';
import '../../data/data_export.dart';
import '../../data/downloads_store.dart';
import '../../data/favourites_store.dart';
import '../../data/iap_store.dart';
import '../../data/profile_store.dart';
import '../../data/progress_store.dart';
import '../../data/settings_store.dart';
import '../../l10n/app_localizations.dart';
import '_profile_support.dart';
import 'medical_disclaimer_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final ctrl = ref.read(settingsProvider.notifier);
    final iap = ref.watch(iapProvider);
    final auth = ref.watch(authProvider);
    final l = L10n.of(context);
    final accountName = auth.user?.displayName ?? l.settingsAccountNameFallback;
    final accountEmail = auth.user?.email ?? l.settingsAccountEmailFallback;
    final subscriptionLabel = iap.isPremium
        ? l.settingsSubscriptionPremiumActive
        : l.settingsSubscriptionFreeTrial;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _TopBar(onBack: () => context.pop()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          sliver: SliverList.list(
            children: [
              Text(l.settingsTitle, style: AppTypography.displayMd),
              const SizedBox(height: AppSpacing.xl),
                      _SectionLabel(l.settingsNotifications),
                      _SettingGroup(
                        children: [
                          _ToggleRow(
                            label: l.settingsDailyReminder,
                            subtitle: _fmtTime(s.dailyReminderTime),
                            value: s.dailyReminder,
                            onChanged: ctrl.setDailyReminder,
                            onSubtitleTap: s.dailyReminder
                                ? () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime: s.dailyReminderTime,
                                    );
                                    if (picked != null) {
                                      await ctrl
                                          .setDailyReminderTime(picked);
                                    }
                                  }
                                : null,
                          ),
                          _ToggleRow(
                            label: l.settingsBedtimeReminder,
                            subtitle: _fmtTime(s.sleepReminderTime),
                            value: s.sleepReminder,
                            onChanged: ctrl.setSleepReminder,
                            onSubtitleTap: s.sleepReminder
                                ? () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime: s.sleepReminderTime,
                                    );
                                    if (picked != null) {
                                      await ctrl
                                          .setSleepReminderTime(picked);
                                    }
                                  }
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _SectionLabel(l.settingsPlayback),
                      _SettingGroup(
                        children: [
                          _ToggleRow(
                            label: l.settingsHaptic,
                            value: s.hapticFeedback,
                            onChanged: ctrl.setHapticFeedback,
                          ),
                          _ToggleRow(
                            label: l.settingsBackgroundAudio,
                            subtitle: l.settingsBackgroundAudioSubtitle,
                            value: s.backgroundAudio,
                            onChanged: ctrl.setBackgroundAudio,
                          ),
                          _ToggleRow(
                            label: l.settingsWifiDownload,
                            value: s.downloadOverWifi,
                            onChanged: ctrl.setDownloadOverWifi,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _SectionLabel(l.settingsAccount),
                      _SettingGroup(
                        children: [
                          _LinkRow(
                            label: l.settingsTheme,
                            value: _themeLabel(s.themeMode, l),
                            onTap: () => _showThemeSheet(
                              context,
                              current: s.themeMode,
                              onPick: ctrl.setThemeMode,
                            ),
                          ),
                          _LinkRow(
                            label: l.settingsLanguage,
                            value: _languageLabel(s.language, l),
                            onTap: () => _showLanguageSheet(
                              context,
                              current: s.language,
                              onPick: ctrl.setLanguage,
                            ),
                          ),
                          _LinkRow(
                            label: l.settingsProfileRow,
                            value: l.settingsAccountSummary(
                              accountName,
                              accountEmail,
                            ),
                            onTap: () {},
                          ),
                          _LinkRow(
                            label: l.settingsSubscription,
                            value: subscriptionLabel,
                            onTap: iap.isPremium
                                ? () => ref
                                    .read(iapProvider.notifier)
                                    .openManageSubscriptions()
                                : () => context.push('/profile/premium'),
                          ),
                          _LinkRow(
                            label: l.settingsWellnessDisclaimer,
                            onTap: () {
                              unawaited(
                                ref.read(analyticsProvider).track(
                                  AnalyticsEvents.disclaimerReopened,
                                ),
                              );
                              unawaited(
                                ref.read(crashReporterProvider).breadcrumb(
                                  AnalyticsEvents.disclaimerReopened,
                                ),
                              );
                              showMedicalDisclaimerDialog(
                                context,
                                requireAcknowledgement: false,
                              );
                            },
                          ),
                          _LinkRow(
                            label: l.settingsCredits,
                            onTap: () =>
                                context.push('/profile/settings/credits'),
                          ),
                          _LinkRow(
                            label: l.settingsPrivacy,
                            onTap: () => context.push('/legal/privacy'),
                          ),
                          _LinkRow(
                            label: l.settingsTerms,
                            onTap: () => context.push('/legal/terms'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _SettingGroup(
                        children: [
                          _ActionRow(
                            key: const Key('settings-action-sign-out'),
                            icon: LucideIcons.logOut,
                            label: l.settingsSignOut,
                            onTap: () =>
                                _confirmSignOut(context, ref: ref),
                          ),
                          _ActionRow(
                            key: const Key('settings-action-export-data'),
                            icon: LucideIcons.download,
                            label: l.settingsExportData,
                            onTap: () => exportUserData(context),
                          ),
                          _ActionRow(
                            key: const Key('settings-action-delete-account'),
                            icon: LucideIcons.trash2,
                            label: l.settingsDeleteAccount,
                            tint: AppColors.error,
                            onTap: () => _confirmDeleteAccount(
                              context,
                              ref: ref,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
              Center(
                child: Text(
                  'Serenity v$appVersion',
                  style: AppTypography.label.copyWith(
                    color: context.palette.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _fmtTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

enum _DeleteAccountAction {
  cancel,
  delete,
  exportThenDelete,
}

Future<void> _confirmDeleteAccount(
  BuildContext context, {
  required WidgetRef ref,
}) async {
  final l = L10n.of(context);
  final action = await showDialog<_DeleteAccountAction>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: ctx.palette.bgMid,
      title: Text(l.settingsDeleteAccountDialogTitle),
      content: Text(l.settingsDeleteAccountDialogBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(_DeleteAccountAction.cancel),
          child: Text(l.settingsCancel),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(ctx).pop(_DeleteAccountAction.exportThenDelete),
          child: Text(l.settingsDeleteAccountExportFirst),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          onPressed: () => Navigator.of(ctx).pop(_DeleteAccountAction.delete),
          child: Text(l.settingsDeleteAccountConfirm),
        ),
      ],
    ),
  );
  if (action == null || action == _DeleteAccountAction.cancel) return;
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.maybeOf(context);
  final exportDeleteMessage =
      l.settingsDeleteAccountExportFirstConfirmation;
  if (action == _DeleteAccountAction.exportThenDelete) {
    await exportUserData(context);
    if (!context.mounted) return;
  }
  await _deleteAccount(
    context,
    ref: ref,
    afterExport: action == _DeleteAccountAction.exportThenDelete,
  );
  if (action == _DeleteAccountAction.exportThenDelete &&
      messenger?.mounted == true) {
    messenger?.showSnackBar(
      SnackBar(content: Text(exportDeleteMessage)),
    );
  }
}

Future<void> _confirmSignOut(
  BuildContext context, {
  required WidgetRef ref,
}) async {
  final l = L10n.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: ctx.palette.bgMid,
      title: Text(l.settingsSignOutDialogTitle),
      content: Text(l.settingsSignOutDialogBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l.settingsCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l.settingsSignOut),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  if (!context.mounted) return;
  await ref.read(authProvider.notifier).signOut();
  if (context.mounted) context.go('/onboarding');
}

Future<void> _deleteAccount(
  BuildContext context, {
  required WidgetRef ref,
  required bool afterExport,
}) async {
  final settings = ref.read(settingsProvider.notifier);
  await settings.setDailyReminder(false);
  await settings.setSleepReminder(false);
  await ref.read(downloadsProvider.notifier).wipeAll();
  await ref.read(favouritesProvider.notifier).wipeAll();
  await ref.read(profileProvider.notifier).wipeAccountData();
  await settings.wipeUserPreferences();
  await ref.read(progressProvider.notifier).reset();
  await ref.read(authProvider.notifier).signOut();
  final event = afterExport
      ? AnalyticsEvents.accountDeletedAfterExport
      : AnalyticsEvents.accountDeleted;
  await ref.read(analyticsProvider).track(event);
  await ref.read(crashReporterProvider).breadcrumb(event);
  if (context.mounted) context.go('/onboarding');
}

String _languageLabel(AppLanguage lang, L10n l) => switch (lang) {
      AppLanguage.system => l.settingsLanguageSystem,
      AppLanguage.en => l.settingsLanguageEnglish,
      AppLanguage.zh => l.settingsLanguageChinese,
    };

String _themeLabel(AppThemeMode mode, L10n l) => switch (mode) {
      AppThemeMode.system => l.settingsThemeSystem,
      AppThemeMode.dark => l.settingsThemeDark,
      AppThemeMode.light => l.settingsThemeLight,
      AppThemeMode.auto => l.settingsThemeAuto,
    };

Future<void> _showThemeSheet(
  BuildContext context, {
  required AppThemeMode current,
  required Future<void> Function(AppThemeMode) onPick,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final l = L10n.of(ctx);
      return Container(
        decoration: BoxDecoration(
          color: ctx.palette.bgMid,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          border: Border(
            top: BorderSide(color: ctx.palette.surfaceBorder),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xl,
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
                    color: ctx.palette.surfaceBorderStrong,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  l.settingsThemeSheetTitle,
                  style: AppTypography.title,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final opt in AppThemeMode.values)
                _LanguageRow(
                  label: _themeLabel(opt, l),
                  selected: opt == current,
                  onTap: () async {
                    await onPick(opt);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _showLanguageSheet(
  BuildContext context, {
  required AppLanguage current,
  required Future<void> Function(AppLanguage) onPick,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final l = L10n.of(ctx);
      return Container(
        decoration: BoxDecoration(
          color: ctx.palette.bgMid,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          border: Border(
            top: BorderSide(color: ctx.palette.surfaceBorder),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xl,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                child: Text(
                  l.settingsLanguageSheetTitle,
                  style: AppTypography.title,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final opt in AppLanguage.values)
                _LanguageRow(
                  label: _languageLabel(opt, l),
                  selected: opt == current,
                  onTap: () async {
                    await onPick(opt);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdR,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: AppTypography.bodyLg),
            ),
            if (selected)
              const Icon(
                LucideIcons.check,
                color: AppColors.brandVioletLight,
              ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      child: Row(
        children: [
          Material(
            color: context.palette.surfaceGlass,
            shape: CircleBorder(
              side: BorderSide(color: context.palette.surfaceBorder),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onBack,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(LucideIcons.chevronLeft, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.label.copyWith(
          color: context.palette.textTertiary,
          fontSize: 11,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _SettingGroup extends StatelessWidget {
  const _SettingGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      glow: GlassGlow.none,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                thickness: 0.5,
                color: context.palette.surfaceBorder,
                indent: AppSpacing.md,
                endIndent: AppSpacing.md,
              ),
          ],
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.onSubtitleTap,
  });

  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onSubtitleTap;

  @override
  Widget build(BuildContext context) {
    Widget body = Text(subtitle ?? '', style: AppTypography.bodyMd);
    if (onSubtitleTap != null) {
      body = GestureDetector(
        onTap: onSubtitleTap,
        behavior: HitTestBehavior.opaque,
        child: Text(
          subtitle!,
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.brandVioletLight,
            decoration: TextDecoration.underline,
            decorationColor:
                AppColors.brandVioletLight.withValues(alpha: 0.4),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.bodyLg),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  body,
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            // In dawn the saturated brand violet reads as a loud dark pill
            // against the cream sky. Use a pastel lilac so the "on" state
            // still reads as brand-coloured but doesn't shout.
            activeThumbColor: context.palette.isDark
                ? context.palette.textPrimary
                : Colors.white,
            activeTrackColor: context.palette.isDark
                ? AppColors.brandViolet
                : const Color(0xFFBCB3ED), // lerp(brandViolet, white, ~0.3)
            inactiveThumbColor: context.palette.textTertiary,
            inactiveTrackColor: context.palette.surfaceGlass,
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, this.value, required this.onTap});
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(label, style: AppTypography.bodyLg),
                  if (value != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        value!,
                        style: AppTypography.bodyMd,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: context.palette.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.tint,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final color = tint ?? context.palette.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLg.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
