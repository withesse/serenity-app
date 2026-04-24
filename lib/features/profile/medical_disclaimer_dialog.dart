import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/profile_store.dart';
import '../../core/theme/app_palette.dart';
import '../../l10n/app_localizations.dart';

Future<bool?> showMedicalDisclaimerDialog(
  BuildContext context, {
  required bool requireAcknowledgement,
}) {
  final l = L10n.of(context);
  return showDialog<bool>(
    context: context,
    barrierDismissible: !requireAcknowledgement,
    builder: (ctx) => PopScope(
      canPop: !requireAcknowledgement,
      child: AlertDialog(
        backgroundColor: ctx.palette.bgMid,
        title: Text(l.medicalDisclaimerTitle),
        content: Text(l.medicalDisclaimerBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(requireAcknowledgement),
            child: Text(
              requireAcknowledgement
                  ? l.medicalDisclaimerAcknowledge
                  : l.settingsCancel,
            ),
          ),
        ],
      ),
    ),
  );
}

class MedicalDisclaimerGate extends ConsumerStatefulWidget {
  const MedicalDisclaimerGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MedicalDisclaimerGate> createState() =>
      _MedicalDisclaimerGateState();
}

class _MedicalDisclaimerGateState extends ConsumerState<MedicalDisclaimerGate> {
  bool _dialogQueued = false;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    if (profile.onboarded &&
        !profile.medicalDisclaimerAcknowledged &&
        !_dialogQueued) {
      _dialogQueued = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final acknowledged = await showMedicalDisclaimerDialog(
          context,
          requireAcknowledgement: true,
        );
        if (acknowledged == true) {
          await ref
              .read(profileProvider.notifier)
              .acknowledgeMedicalDisclaimer();
        }
        if (mounted) {
          setState(() => _dialogQueued = false);
        }
      });
    }

    return widget.child;
  }
}
