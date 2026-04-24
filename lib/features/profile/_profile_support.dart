import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';

const supportEmail = 'support@serenity.app';
const appVersion = '0.1.0';

final supportEmailUri = Uri(
  scheme: 'mailto',
  path: supportEmail,
  queryParameters: {'subject': 'Serenity support'},
);

Future<void> openSupportEmail(
  BuildContext context, {
  Future<bool> Function(Uri uri)? launcher,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final failureMessage = L10n.of(context).profileHelpLaunchFailed;
  final didLaunch = await (launcher ?? launchUrl)(supportEmailUri);
  if (!didLaunch) {
    messenger?.showSnackBar(SnackBar(content: Text(failureMessage)));
  }
}

class ProfileDetailTopBar extends StatelessWidget {
  const ProfileDetailTopBar({super.key, required this.onBack});

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
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
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
      ),
    );
  }
}

class ProfileSectionLabel extends StatelessWidget {
  const ProfileSectionLabel(this.text, {super.key});

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
