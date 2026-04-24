import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/library/library_data.dart';
import 'progress_store.dart';

/// Pushes a snapshot of tonight's recommended session + current streak
/// into the App Group that the iOS Widget reads. Safe to call on any
/// platform — `MissingPluginException` from Android / early iOS builds
/// without the native channel is swallowed.
///
/// Paired with:
///   - `ios/SerenityWidget/SerenityWidget.swift` (UserDefaults reader)
///   - App Group `group.com.serenity.serenity_app` enabled on both the
///     Runner target and the Widget Extension target in Xcode
///
/// The Swift side of the channel is intentionally not registered yet — the
/// Widget Extension target has to be created first. Until then this class
/// is dark; the provider below still fires so the wiring shows up in
/// analytics breadcrumbs and can be validated when the extension lands.
class WidgetBridge {
  WidgetBridge._();

  static const _channel = MethodChannel('serenity/widget');

  static Future<void> pushTonight({
    required String sessionId,
    required String sessionTitle,
    required int streak,
  }) async {
    try {
      await _channel.invokeMethod<void>('pushTonight', {
        'sessionId': sessionId,
        'sessionTitle': sessionTitle,
        'streak': streak,
      });
    } on MissingPluginException {
      // No native handler yet — see class doc.
    }
  }
}

/// Side-effect provider — watches progress and pushes to the widget on
/// every change. Kept as a top-level Provider rather than a `ref.listen`
/// inside a widget so the update fires even when Home isn't currently
/// mounted (e.g. user is on the Library tab).
final widgetStateSyncProvider = Provider<void>((ref) {
  final streak = ref.watch(progressProvider.select((s) => s.currentStreak));
  final tonight = tonightRecommendation();
  WidgetBridge.pushTonight(
    sessionId: tonight.id,
    sessionTitle: tonight.title,
    streak: streak,
  );
});
