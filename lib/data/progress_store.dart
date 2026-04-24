import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../features/profile/progress_data.dart'
    show DayEntry, Achievement, AchievementMetric;
import 'clock.dart';

/// Real, persisted meditation progress. Replaces `mockProgress()` at runtime.
///
/// Storage model — kept deliberately simple (a `dynamic` Hive box with plain
/// types) so we don't need generated adapters:
///   - `daysMinutes`  : `List<int>`  — oldest-first, newest at the last index.
///                      `_read()` rolls stale windows forward relative to
///                      `lastSessionDate` so the exposed state always ends at
///                      the real calendar day for `DateTime.now()`.
///   - `currentStreak`: `int`
///   - `longestStreak`: `int`
///   - `totalMinutes` : `int`
///   - `sessionsCompleted` : `int`
///   - `lastSessionDate`: `String`  ISO date (yyyy-MM-dd) — used to detect
///                                    whether a new day has begun so the
///                                    streak can roll forward or reset.
@immutable
class ProgressState {
  const ProgressState({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalMinutes,
    required this.sessionsCompleted,
    required this.days,
    required this.achievements,
    required this.freezeAvailable,
  });

  final int currentStreak;
  final int longestStreak;
  final int totalMinutes;
  final int sessionsCompleted;
  final List<DayEntry> days; // oldest → newest, length 35
  final List<Achievement> achievements;

  /// One freeze token per ISO week. `true` if the user has not yet spent
  /// it. Auto-regenerates on Monday because the stored "last used" week
  /// stops matching the current week.
  final bool freezeAvailable;
}

class ProgressController extends Notifier<ProgressState> {
  static const _boxName = 'progress';
  static const _windowLen = 35;

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  @override
  ProgressState build() {
    _seedIfEmpty();
    return _read();
  }

  // --- Seed / migrate ---

  void _seedIfEmpty() {
    if (_box.get('seeded') == true) return;
    // Seed with the same varied pattern we showed in the UI mock so a fresh
    // install still looks lived-in. A real app would start from zero.
    const seed = [
      0, 8, 5, 12, 10, 15, 6, 18, 0, 22,
      14, 10, 8, 14, 0, 0, 12, 6, 18, 10,
      12, 15, 18, 10, 14, 20, 8, 10, 14,
      12, 18, 10, 20, 8, 15, 14,
    ];
    _box.put('daysMinutes', List<int>.from(seed.reversed.take(_windowLen)));
    _box.put('currentStreak', 7);
    _box.put('longestStreak', 21);
    _box.put('totalMinutes', seed.fold<int>(0, (a, m) => a + m));
    _box.put('sessionsCompleted', 42);
    _box.put('lastSessionDate', _today());
    _box.put('seeded', true);
  }

  ProgressState _read() {
    final today = _today();
    final minutes = _rolledDaysMinutes(today: today);
    final anchor = DateTime.parse(today);
    final days = <DayEntry>[];
    for (var i = 0; i < _windowLen; i++) {
      final date = DateTime(anchor.year, anchor.month, anchor.day)
          .subtract(Duration(days: _windowLen - 1 - i));
      days.add(DayEntry(date, minutes[i]));
    }

    return ProgressState(
      currentStreak: _box.get('currentStreak', defaultValue: 0) as int,
      longestStreak: _box.get('longestStreak', defaultValue: 0) as int,
      totalMinutes: _box.get('totalMinutes', defaultValue: 0) as int,
      sessionsCompleted:
          _box.get('sessionsCompleted', defaultValue: 0) as int,
      days: days,
      achievements: _computeAchievements(
        _box.get('sessionsCompleted', defaultValue: 0) as int,
        _box.get('currentStreak', defaultValue: 0) as int,
        _box.get('totalMinutes', defaultValue: 0) as int,
      ),
      freezeAvailable: _freezeAvailable(),
    );
  }

  bool _freezeAvailable() {
    final last = _box.get('freezeUsedWeek') as String?;
    return last != _currentIsoWeek(now: ref.read(clockProvider)());
  }

  // --- Public mutations ---

  /// Record a completed session of [minutes] minutes. Rolls the streak
  /// forward (or resets it) based on whether the previous session was
  /// today or yesterday.
  Future<void> recordSession(int minutes) async {
    final today = _today();
    final last = _box.get('lastSessionDate') as String?;
    final daysMinutes = _rolledDaysMinutes(
      today: today,
      lastSessionDate: last,
    );
    daysMinutes[daysMinutes.length - 1] =
        daysMinutes[daysMinutes.length - 1] + minutes;

    var streak = _box.get('currentStreak', defaultValue: 0) as int;
    String? freezeUsedWeek = _box.get('freezeUsedWeek') as String?;
    if (last == null) {
      streak = 1;
    } else if (last == today) {
      // same day — streak unchanged
    } else if (_isYesterday(last, today)) {
      streak += 1;
    } else if (_isTwoDaysAgo(last, today) &&
        freezeUsedWeek != _currentIsoWeek(now: ref.read(clockProvider)())) {
      // Exactly one missed day and freeze available — keep the streak and
      // spend the weekly token. The streak still advances by 1 so a user
      // who meditates day-on/day-off with a save isn't worse off than one
      // who lucked into a perfect run.
      streak += 1;
      freezeUsedWeek = _currentIsoWeek(now: ref.read(clockProvider)());
    } else {
      streak = 1;
    }

    final longest = _box.get('longestStreak', defaultValue: 0) as int;
    final totalMinutes =
        (_box.get('totalMinutes', defaultValue: 0) as int) + minutes;
    final sessions =
        (_box.get('sessionsCompleted', defaultValue: 0) as int) + 1;

    await _box.putAll({
      'daysMinutes': daysMinutes,
      'currentStreak': streak,
      'longestStreak': streak > longest ? streak : longest,
      'totalMinutes': totalMinutes,
      'sessionsCompleted': sessions,
      'lastSessionDate': today,
      'freezeUsedWeek': ?freezeUsedWeek,
    });

    state = _read();
  }

  /// Wipe everything — used by "Sign out" or a dev-only reset button.
  Future<void> reset() async {
    await _box.clear();
    await _box.put('seeded', true);
    state = _read();
  }

  // --- Helpers ---

  List<int> _rolledDaysMinutes({
    required String today,
    String? lastSessionDate,
  }) {
    final raw =
        ((_box.get('daysMinutes') as List?)?.cast<int>().toList()) ?? <int>[];
    return _rollWindowForward(
      raw,
      lastSessionDate: lastSessionDate ?? _box.get('lastSessionDate') as String?,
      today: today,
    );
  }

  static List<int> _rollWindowForward(
    List<int> raw, {
    required String today,
    String? lastSessionDate,
  }) {
    final normalized = _normalizeWindow(raw);
    if (lastSessionDate == null) return normalized;

    final dayGap =
        DateTime.parse(today).difference(DateTime.parse(lastSessionDate)).inDays;
    if (dayGap <= 0) return normalized;
    if (dayGap >= _windowLen) return List<int>.filled(_windowLen, 0);

    return <int>[
      ...normalized.sublist(dayGap),
      ...List<int>.filled(dayGap, 0),
    ];
  }

  static List<int> _normalizeWindow(List<int> raw) {
    if (raw.length >= _windowLen) {
      return List<int>.from(raw.skip(raw.length - _windowLen));
    }

    return ListQueue<int>.from([
      ...List<int>.filled(_windowLen - raw.length, 0),
      ...raw,
    ]).toList(growable: true);
  }

  String _today() {
    final n = ref.read(clockProvider)();
    return '${n.year.toString().padLeft(4, '0')}-'
        '${n.month.toString().padLeft(2, '0')}-'
        '${n.day.toString().padLeft(2, '0')}';
  }

  static bool _isYesterday(String last, String today) {
    final t = DateTime.parse(today);
    final l = DateTime.parse(last);
    return t.difference(l).inDays == 1;
  }

  /// Exactly one calendar day between `last` and `today`, i.e. the user
  /// missed yesterday but meditated today — the scenario a freeze covers.
  static bool _isTwoDaysAgo(String last, String today) {
    final t = DateTime.parse(today);
    final l = DateTime.parse(last);
    return t.difference(l).inDays == 2;
  }

  /// ISO-year-week key like `2026-W17`. Used as the bucket for the weekly
  /// freeze: one token per bucket, refills automatically when the week
  /// rolls over. The ISO year/week is determined by the Thursday in the
  /// current week, then counted from the Monday of the week containing Jan 4.
  static String _currentIsoWeek({DateTime? now}) {
    final source = now ?? DateTime.now();
    final date = DateTime.utc(source.year, source.month, source.day);
    final thursday = date.add(
      Duration(days: DateTime.thursday - date.weekday),
    );
    final isoYear = thursday.year;
    final weekOneAnchor = DateTime.utc(isoYear, 1, 4);
    final weekOneMonday = weekOneAnchor.subtract(
      Duration(days: weekOneAnchor.weekday - DateTime.monday),
    );
    final currentMonday = thursday.subtract(
      Duration(days: thursday.weekday - DateTime.monday),
    );
    final week =
        1 + (currentMonday.difference(weekOneMonday).inDays ~/ DateTime.daysPerWeek);
    return '$isoYear-W${week.toString().padLeft(2, '0')}';
  }

  @visibleForTesting
  static String isoWeekFor(DateTime now) => _currentIsoWeek(now: now);

  List<Achievement> _computeAchievements(
      int sessions, int streak, int totalMinutes) {
    return [
      Achievement(
        id: 'first-breath',
        title: 'First Breath',
        subtitle: 'Completed your first session',
        metric: AchievementMetric.sessions,
        target: 1,
        progress: sessions,
      ),
      Achievement(
        id: 'seven-nights',
        title: 'Seven Nights',
        subtitle: '7-day streak',
        metric: AchievementMetric.streak,
        target: 7,
        progress: streak,
      ),
      Achievement(
        id: 'night-watcher',
        title: 'Night Watcher',
        subtitle: '10 sessions completed',
        metric: AchievementMetric.sessions,
        target: 10,
        progress: sessions,
      ),
      Achievement(
        id: 'deep-well',
        title: 'Deep Well',
        subtitle: '500 minutes meditated',
        metric: AchievementMetric.minutes,
        target: 500,
        progress: totalMinutes,
      ),
      Achievement(
        id: 'constellation',
        title: 'Constellation',
        subtitle: '30-day streak',
        metric: AchievementMetric.streak,
        target: 30,
        progress: streak,
      ),
    ];
  }
}

final progressProvider =
    NotifierProvider<ProgressController, ProgressState>(
  ProgressController.new,
);

/// Resolver for the detail screen — handy because go_router only has the id
/// in the path params and we want the live Achievement with its current
/// progress, not a stale snapshot threaded through `extra`.
Achievement? achievementById(ProgressState state, String id) {
  for (final a in state.achievements) {
    if (a.id == id) return a;
  }
  return null;
}
