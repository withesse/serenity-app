import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'crash_reporter.dart';

/// Uniform error routing for any `try/catch` inside provider code.
///
/// Before this helper existed, caught exceptions were handled ad-hoc — some
/// called `debugPrint`, some sank silently, some called `crashReporter`
/// directly. That meant when Sentry gets wired in real, coverage depends
/// on whether each individual call site remembered to forward the error.
///
/// Usage:
/// ```dart
/// try {
///   await _audio.setAudioSource(...);
/// } catch (e, st) {
///   reportError(ref, e, st, context: 'audio_load');
/// }
/// ```
///
/// Effects:
///   1. `crashReporterProvider.recordError(..., fatal: false)` — sent to
///      Sentry / Crashlytics / etc once the real backend is bound.
///   2. `crashReporterProvider.breadcrumb(context, data: {...})` — leaves
///      a trail in the event's breadcrumb list so the preceding state is
///      visible when triaging.
///   3. `debugPrint` in debug mode only, prefixed with the context.
///
/// The call is intentionally fire-and-forget for the caller — catch block
/// stays synchronous. Any async I/O the reporter does runs on the
/// microtask queue.
/// Accepts any Ref-like handle (`Ref` inside providers, `WidgetRef`
/// inside ConsumerWidget build methods). Both have `.read(provider)` —
/// the helper only needs that. Keeping the parameter typed as the
/// shared supertype would ideally be cleaner, but Riverpod doesn't
/// export one, so `dynamic` plus the in-line shape check is the
/// pragmatic compromise.
void reportError(
  Object ref,
  Object error,
  StackTrace? stack, {
  String? context,
  Map<String, Object?>? data,
}) {
  assert(
    ref is Ref || ref is WidgetRef,
    'reportError expects a Ref or WidgetRef',
  );
  final reader = ref as dynamic;
  final reporter = reader.read(crashReporterProvider) as dynamic;
  // ignore: discarded_futures
  reporter.recordError(error, stack, fatal: false);
  if (context != null) {
    // ignore: discarded_futures
    reporter.breadcrumb(context, data: data);
  }
  if (kDebugMode) {
    final tag = context != null ? '[$context] ' : '';
    debugPrint('$tag$error');
    if (stack != null) debugPrint(stack.toString());
  }
}
