import 'dart:io' show Platform;

import 'package:health/health.dart';

/// Wraps the `health` plugin for the only two operations Serenity cares
/// about: writing a completed session to Mindful Minutes and reading back
/// the weekly total for the Progress screen (future feature).
///
/// Android is a no-op — Google Fit / Health Connect have different mindful
/// semantics. This is iOS-first.
class HealthService {
  HealthService._();

  static final _health = Health();
  static bool _configured = false;

  static List<HealthDataType> get _types =>
      const [HealthDataType.MINDFULNESS];

  static Future<bool> _ensureConfigured() async {
    if (_configured) return true;
    if (!Platform.isIOS) return false;
    _health.configure();
    _configured = true;
    return true;
  }

  /// Prompt once for write permission. Safe to call multiple times — the OS
  /// will only surface the sheet the first time.
  static Future<bool> requestPermission() async {
    if (!await _ensureConfigured()) return false;
    final permissions = _types.map((_) => HealthDataAccess.WRITE).toList();
    return await _health.requestAuthorization(_types, permissions: permissions);
  }

  /// Write a completed meditation session of [minutes] minutes ending
  /// [endedAt] (default: now) to HealthKit's Mindful Minutes category.
  static Future<bool> logMindfulMinutes(
    int minutes, {
    DateTime? endedAt,
  }) async {
    if (!await _ensureConfigured()) return false;
    final end = endedAt ?? DateTime.now();
    final start = end.subtract(Duration(minutes: minutes));
    // No try/catch here — callers wrap in reportError(ref, ...) so the
    // crash reporter gets the full picture. Falling into the catch was
    // previously the only place HealthKit write failures went.
    return await _health.writeHealthData(
      value: 0, // MINDFULNESS sessions have no numeric value, only interval
      type: HealthDataType.MINDFULNESS,
      startTime: start,
      endTime: end,
    );
  }
}
