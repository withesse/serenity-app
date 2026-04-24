import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'analytics.dart';
import 'clock.dart';
import 'notifications.dart' as notif;

/// Persisted user preferences. Boxed in Hive so toggles survive app restarts.
/// Language override. `system` defers to the OS locale.
enum AppLanguage { system, en, zh }

/// Theme override. `system` defers to the OS preference; `auto` switches
/// between dark (night) and light (dawn) based on the local clock.
enum AppThemeMode { system, dark, light, auto }

/// Hours at which the auto theme switches. Dawn from 6:00 to 18:00, night
/// otherwise — tuned so the theme matches the UX metaphor (dawn / night sky)
/// rather than blindly tracking sunset.
const _autoDawnHour = 6;
const _autoDuskHour = 18;

@immutable
class SettingsState {
  const SettingsState({
    required this.dailyReminder,
    required this.dailyReminderTime,
    required this.sleepReminder,
    required this.sleepReminderTime,
    required this.hapticFeedback,
    required this.backgroundAudio,
    required this.downloadOverWifi,
    required this.language,
    required this.themeMode,
  });

  final bool dailyReminder;
  final TimeOfDay dailyReminderTime;
  final bool sleepReminder;
  final TimeOfDay sleepReminderTime;
  final bool hapticFeedback;
  final bool backgroundAudio;
  final bool downloadOverWifi;
  final AppLanguage language;
  final AppThemeMode themeMode;

  SettingsState copyWith({
    bool? dailyReminder,
    TimeOfDay? dailyReminderTime,
    bool? sleepReminder,
    TimeOfDay? sleepReminderTime,
    bool? hapticFeedback,
    bool? backgroundAudio,
    bool? downloadOverWifi,
    AppLanguage? language,
    AppThemeMode? themeMode,
  }) =>
      SettingsState(
        dailyReminder: dailyReminder ?? this.dailyReminder,
        dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
        sleepReminder: sleepReminder ?? this.sleepReminder,
        sleepReminderTime: sleepReminderTime ?? this.sleepReminderTime,
        hapticFeedback: hapticFeedback ?? this.hapticFeedback,
        backgroundAudio: backgroundAudio ?? this.backgroundAudio,
        downloadOverWifi: downloadOverWifi ?? this.downloadOverWifi,
        language: language ?? this.language,
        themeMode: themeMode ?? this.themeMode,
      );
}

class SettingsController extends Notifier<SettingsState> {
  static const _boxName = 'settings';
  // Per-controller key namespace — protects the shared `settings` box from
  // silent key collisions across Favourites / Profile / Downloads / etc.
  // Legacy unprefixed keys are migrated on first build() and deleted.
  static const _prefix = 'settings.';
  static const _kDailyReminder = '${_prefix}dailyReminder';
  static const _kDailyReminderTime = '${_prefix}dailyReminderTime';
  static const _kSleepReminder = '${_prefix}sleepReminder';
  static const _kSleepReminderTime = '${_prefix}sleepReminderTime';
  static const _kHaptic = '${_prefix}hapticFeedback';
  static const _kBackgroundAudio = '${_prefix}backgroundAudio';
  static const _kDownloadOverWifi = '${_prefix}downloadOverWifi';
  static const _kLanguage = '${_prefix}language';
  static const _kThemeMode = '${_prefix}themeMode';

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  @override
  SettingsState build() {
    _migrateLegacyKeys();
    final langCode = _box.get(_kLanguage, defaultValue: 'system') as String;
    final language = switch (langCode) {
      'en' => AppLanguage.en,
      'zh' => AppLanguage.zh,
      _ => AppLanguage.system,
    };
    final themeCode =
        _box.get(_kThemeMode, defaultValue: 'system') as String;
    final themeMode = switch (themeCode) {
      'dark' => AppThemeMode.dark,
      'light' => AppThemeMode.light,
      'auto' => AppThemeMode.auto,
      _ => AppThemeMode.system,
    };
    return SettingsState(
      dailyReminder: _box.get(_kDailyReminder, defaultValue: true) as bool,
      dailyReminderTime: _readTime(
        _kDailyReminderTime,
        const TimeOfDay(hour: 21, minute: 0),
      ),
      sleepReminder: _box.get(_kSleepReminder, defaultValue: true) as bool,
      sleepReminderTime: _readTime(
        _kSleepReminderTime,
        const TimeOfDay(hour: 22, minute: 30),
      ),
      hapticFeedback: _box.get(_kHaptic, defaultValue: true) as bool,
      backgroundAudio:
          _box.get(_kBackgroundAudio, defaultValue: true) as bool,
      downloadOverWifi:
          _box.get(_kDownloadOverWifi, defaultValue: true) as bool,
      language: language,
      themeMode: themeMode,
    );
  }

  /// One-shot migration from pre-namespace keys (shipped before the
  /// settings-box collision hardening). Runs synchronously during build()
  /// so no async state flicker is visible to the UI.
  static const _legacyRename = <String, String>{
    'dailyReminder': _kDailyReminder,
    'dailyReminderTime': _kDailyReminderTime,
    'sleepReminder': _kSleepReminder,
    'sleepReminderTime': _kSleepReminderTime,
    'hapticFeedback': _kHaptic,
    'backgroundAudio': _kBackgroundAudio,
    'downloadOverWifi': _kDownloadOverWifi,
    'language': _kLanguage,
    'themeMode': _kThemeMode,
  };

  void _migrateLegacyKeys() {
    for (final entry in _legacyRename.entries) {
      if (!_box.containsKey(entry.key)) continue;
      if (!_box.containsKey(entry.value)) {
        _box.put(entry.value, _box.get(entry.key));
      }
      // Always delete the legacy key once we've observed it, so a
      // half-completed migration from a crash doesn't leave an orphan
      // that wipe paths would otherwise miss.
      _box.delete(entry.key);
    }
  }

  TimeOfDay _readTime(String key, TimeOfDay fallback) {
    final raw = _box.get(key) as String?;
    if (raw == null) return fallback;
    final parts = raw.split(':');
    if (parts.length != 2) return fallback;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return fallback;
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> _put(String key, bool value) async {
    await _box.put(key, value);
  }

  Future<void> setDailyReminder(bool v) async {
    await _put(_kDailyReminder, v);
    state = state.copyWith(dailyReminder: v);
    if (v) {
      final granted = await notif.NotificationService.requestPermission();
      if (granted) {
        await _rescheduleDaily(state.dailyReminderTime);
      } else {
        // OS denied — roll the toggle back so it reflects reality.
        await _put(_kDailyReminder, false);
        state = state.copyWith(dailyReminder: false);
      }
    } else {
      await notif.NotificationService.setDailyReminder(time: null);
    }
  }

  Future<void> setSleepReminder(bool v) async {
    await _put(_kSleepReminder, v);
    state = state.copyWith(sleepReminder: v);
    if (v) {
      final granted = await notif.NotificationService.requestPermission();
      if (granted) {
        await _rescheduleSleep(state.sleepReminderTime);
      } else {
        await _put(_kSleepReminder, false);
        state = state.copyWith(sleepReminder: false);
      }
    } else {
      await notif.NotificationService.setBedtimeReminder(time: null);
    }
  }

  Future<void> setDailyReminderTime(TimeOfDay t) async {
    await _box.put(_kDailyReminderTime, '${t.hour}:${t.minute}');
    state = state.copyWith(dailyReminderTime: t);
    if (state.dailyReminder) await _rescheduleDaily(t);
  }

  Future<void> setSleepReminderTime(TimeOfDay t) async {
    await _box.put(_kSleepReminderTime, '${t.hour}:${t.minute}');
    state = state.copyWith(sleepReminderTime: t);
    if (state.sleepReminder) await _rescheduleSleep(t);
  }

  Future<void> _rescheduleDaily(TimeOfDay t) async {
    await notif.NotificationService.setDailyReminder(
      time: notif.TimeOfDay(hour: t.hour, minute: t.minute),
    );
  }

  Future<void> _rescheduleSleep(TimeOfDay t) async {
    await notif.NotificationService.setBedtimeReminder(
      time: notif.TimeOfDay(hour: t.hour, minute: t.minute),
    );
  }

  Future<void> setHapticFeedback(bool v) async {
    await _put(_kHaptic, v);
    state = state.copyWith(hapticFeedback: v);
  }

  Future<void> setBackgroundAudio(bool v) async {
    await _put(_kBackgroundAudio, v);
    state = state.copyWith(backgroundAudio: v);
  }

  Future<void> setDownloadOverWifi(bool v) async {
    await _put(_kDownloadOverWifi, v);
    state = state.copyWith(downloadOverWifi: v);
  }

  Future<void> setLanguage(AppLanguage v) async {
    await _box.put(_kLanguage, v.name);
    state = state.copyWith(language: v);
    await ref.read(analyticsProvider).track(
      AnalyticsEvents.languageChanged,
      {'language': v.name},
    );
  }

  Future<void> setThemeMode(AppThemeMode v) async {
    await _box.put(_kThemeMode, v.name);
    state = state.copyWith(themeMode: v);
    await ref.read(analyticsProvider).track(
      AnalyticsEvents.themeChanged,
      {'mode': v.name},
    );
  }

  Future<void> wipeUserPreferences() async {
    // Delete both the namespaced keys and any pre-migration leftovers.
    // A user who crashed mid-migration could hold both; wipe must drain
    // the entire couple or the reopened app would rehydrate stale data.
    await _box.deleteAll([
      _kDailyReminder,
      _kDailyReminderTime,
      _kSleepReminder,
      _kSleepReminderTime,
      _kHaptic,
      _kBackgroundAudio,
      _kDownloadOverWifi,
      _kLanguage,
      _kThemeMode,
      ..._legacyRename.keys,
    ]);
    state = build();
  }
}

/// Derived: the effective [Locale] to pass to MaterialApp.
/// Returning `null` means "follow OS locale".
final localeProvider = Provider<Locale?>((ref) {
  final lang = ref.watch(settingsProvider.select((s) => s.language));
  return switch (lang) {
    AppLanguage.en => const Locale('en'),
    AppLanguage.zh => const Locale('zh'),
    AppLanguage.system => null,
  };
});

/// Ticks whenever the auto-theme boundary (dawn/dusk) is next crossed, so
/// the theme can flip live without a restart. Reading `now` schedules a
/// self-invalidation at the next boundary; the provider disposes its timer
/// when no longer watched. Call [autoThemeClockProvider.notifier.resume]
/// from an AppLifecycleListener to snap back to the correct theme after
/// the OS has suspended us past a boundary.
class _AutoThemeClock extends Notifier<DateTime> {
  Timer? _timer;

  @override
  DateTime build() {
    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });
    final now = ref.read(clockProvider)();
    _scheduleNextBoundary(now);
    return now;
  }

  void _scheduleNextBoundary(DateTime now) {
    _timer?.cancel();
    final hour = now.hour;
    final next = hour < _autoDawnHour
        ? DateTime(now.year, now.month, now.day, _autoDawnHour)
        : hour < _autoDuskHour
            ? DateTime(now.year, now.month, now.day, _autoDuskHour)
            : DateTime(now.year, now.month, now.day + 1, _autoDawnHour);
    _timer = Timer(next.difference(now), resume);
  }

  /// Re-read the clock and reschedule — called on boundary tick and on
  /// app lifecycle resume (so background suspensions can't freeze us on
  /// the wrong side of a boundary).
  void resume() {
    final now = ref.read(clockProvider)();
    state = now;
    _scheduleNextBoundary(now);
  }

  @visibleForTesting
  Timer? get debugTimer => _timer;
}

final autoThemeClockProvider =
    NotifierProvider.autoDispose<_AutoThemeClock, DateTime>(_AutoThemeClock.new);

/// Derived: Flutter's [ThemeMode] from our persisted preference.
final themeModeProvider = Provider<ThemeMode>((ref) {
  final mode = ref.watch(settingsProvider.select((s) => s.themeMode));
  if (mode == AppThemeMode.auto) {
    final now = ref.watch(autoThemeClockProvider);
    final h = now.hour;
    final isDawn = h >= _autoDawnHour && h < _autoDuskHour;
    return isDawn ? ThemeMode.light : ThemeMode.dark;
  }
  return switch (mode) {
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.auto => ThemeMode.system, // unreachable — handled above
  };
});

final settingsProvider =
    NotifierProvider<SettingsController, SettingsState>(
  SettingsController.new,
);
