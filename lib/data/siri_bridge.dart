import 'package:flutter/services.dart';

/// Dart caller for the native [`SiriBridge`](../../ios/Runner/SiriShortcuts.swift)
/// MethodChannel. Donates an NSUserActivity so iOS surfaces "Begin <title>"
/// in Siri / Spotlight / Shortcuts. No-ops on Android (falls through
/// `MissingPluginException` silently) and on iOS until the Swift side is
/// registered in AppDelegate.
class SiriBridge {
  SiriBridge._();

  static const _channel = MethodChannel('serenity/siri');

  static Future<void> donate({
    required String sessionId,
    required String title,
  }) async {
    try {
      await _channel.invokeMethod<void>('donate', {
        'sessionId': sessionId,
        'title': title,
      });
    } on MissingPluginException {
      // Expected on Android and on iOS builds that haven't wired
      // SiriBridge.register in AppDelegate yet — swallow rather than
      // spamming Sentry for an optional platform integration.
    }
  }
}
