import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_store.dart';

/// Thin wrapper around [HapticFeedback] that consults
/// `SettingsState.hapticFeedback` before firing. Widgets should call
/// `ref.read(hapticsProvider).light()` instead of `HapticFeedback.lightImpact`
/// directly so the user's toggle is actually honoured.
class Haptics {
  Haptics(this._enabled);
  final bool _enabled;

  Future<void> light() async {
    if (_enabled) await HapticFeedback.lightImpact();
  }

  Future<void> medium() async {
    if (_enabled) await HapticFeedback.mediumImpact();
  }

  Future<void> selection() async {
    if (_enabled) await HapticFeedback.selectionClick();
  }
}

final hapticsProvider = Provider<Haptics>((ref) {
  final enabled =
      ref.watch(settingsProvider.select((s) => s.hapticFeedback));
  return Haptics(enabled);
});
