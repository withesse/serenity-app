import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The single source of truth for "now" inside provider code.
///
/// Overriding this in a ProviderContainer lets tests freeze the clock
/// without passing a DateTime through every call site:
///
/// ```dart
/// ProviderContainer(overrides: [
///   clockProvider.overrideWithValue(() => DateTime(2026, 1, 1)),
/// ]);
/// ```
///
/// Non-provider code (static helpers, pure functions) should still take a
/// `DateTime? now` parameter — see `ProgressController.isoWeekFor` for the
/// shape. Providers call this clock and pass the result down.
typedef Clock = DateTime Function();

final clockProvider = Provider<Clock>((_) => DateTime.now);
