import 'package:flutter/foundation.dart';

import 'crash_reporter.dart';

/// Sentry binding for [CrashReporter]. Kept in a separate file so the
/// lightweight [DebugCrashReporter] can live in debug/free builds without
/// pulling the Sentry SDK.
///
/// To activate (release build):
///   1. `flutter pub add sentry_flutter`
///   2. Replace the two lines marked `SENTRY:` below with the real calls
///      (they're string-stubbed so this file still compiles without the
///      dependency installed).
///   3. In `main.dart`:
///        ```
///        await SentryFlutter.init(
///          (opts) {
///            opts.dsn = const String.fromEnvironment('SENTRY_DSN');
///            opts.tracesSampleRate = 0.2;
///          },
///          appRunner: () => runApp(
///            ProviderScope(
///              overrides: [
///                crashReporterProvider
///                    .overrideWithValue(const SentryCrashReporter()),
///              ],
///              child: const SerenityApp(),
///            ),
///          ),
///        );
///        ```
///      and call `SentryCrashReporter().install()` before anything else.
///   4. Pass `--dart-define=SENTRY_DSN=https://...` at build time so the
///      DSN is never committed. Debug builds keep the no-op debug reporter.
class SentryCrashReporter implements CrashReporter {
  const SentryCrashReporter();

  @override
  Future<void> recordError(Object error, StackTrace? stack,
      {bool fatal = false}) async {
    // SENTRY: await Sentry.captureException(error, stackTrace: stack);
    debugPrint('[sentry.stub] $error');
  }

  @override
  Future<void> setUser(String? id) async {
    // SENTRY: Sentry.configureScope((s) => s.setUser(SentryUser(id: id)));
  }

  @override
  Future<void> breadcrumb(String message, {Map<String, Object?>? data}) async {
    // SENTRY: Sentry.addBreadcrumb(Breadcrumb(message: message, data: data));
  }

  @override
  void install() {
    final previousFlutter = FlutterError.onError;
    FlutterError.onError = (details) {
      recordError(details.exception, details.stack, fatal: false);
      previousFlutter?.call(details);
    };
  }
}
