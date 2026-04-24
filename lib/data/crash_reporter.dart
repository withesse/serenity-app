import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Error reporting interface. Swapped for Sentry / Crashlytics / Bugsnag
/// at release time by rebinding [crashReporterProvider]; every call site
/// goes through this shim so the concrete SDK doesn't leak into feature
/// code. [install] wires FlutterError.onError and PlatformDispatcher.onError
/// exactly once — call it from `main`.
abstract class CrashReporter {
  Future<void> recordError(Object error, StackTrace? stack, {bool fatal = false});
  Future<void> setUser(String? id);
  Future<void> breadcrumb(String message, {Map<String, Object?>? data});

  /// Hooks the Flutter and Dart error channels. Safe to call more than
  /// once — the stock handlers are preserved and re-invoked so we compose
  /// with other wiring (notifications, audio_session) that sometimes
  /// installs its own handlers.
  void install() {
    final previousFlutter = FlutterError.onError;
    FlutterError.onError = (details) {
      recordError(details.exception, details.stack, fatal: false);
      previousFlutter?.call(details);
    };
    final previousPlatform = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      recordError(error, stack, fatal: true);
      return previousPlatform?.call(error, stack) ?? false;
    };
  }
}

class DebugCrashReporter implements CrashReporter {
  const DebugCrashReporter();

  @override
  Future<void> recordError(Object error, StackTrace? stack,
      {bool fatal = false}) async {
    if (!kDebugMode) return;
    debugPrint('[crash${fatal ? '.fatal' : ''}] $error');
    if (stack != null) debugPrint(stack.toString());
  }

  @override
  Future<void> setUser(String? id) async {
    if (!kDebugMode) return;
    debugPrint('[crash] user=$id');
  }

  @override
  Future<void> breadcrumb(String message, {Map<String, Object?>? data}) async {
    if (!kDebugMode) return;
    debugPrint('[crash.trace] $message ${data ?? ''}');
  }

  @override
  void install() {
    final previousFlutter = FlutterError.onError;
    FlutterError.onError = (details) {
      recordError(details.exception, details.stack, fatal: false);
      previousFlutter?.call(details);
    };
    final previousPlatform = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      recordError(error, stack, fatal: true);
      return previousPlatform?.call(error, stack) ?? false;
    };
  }
}

final crashReporterProvider =
    Provider<CrashReporter>((_) => const DebugCrashReporter());
