import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/profile/progress_data.dart';
import 'clock.dart';
import 'mood_store.dart';
import 'progress_store.dart';

/// Rolled-up numbers for the "This week" card on Progress. Derived from the
/// last 14 days of the 35-day window so we can compute a week-over-week
/// delta. Mood average is null when there are no check-ins this week —
/// the UI suppresses that row rather than showing a bogus 0.
@immutable
class WeeklyInsights {
  const WeeklyInsights({
    required this.daysPracticed,
    required this.minutesThisWeek,
    required this.minutesLastWeek,
    required this.averageMood,
  });

  final int daysPracticed;
  final int minutesThisWeek;
  final int minutesLastWeek;
  final double? averageMood;

  int get minutesDelta => minutesThisWeek - minutesLastWeek;
}

/// `days` is oldest → newest, length 35 (see [ProgressController]), so the
/// trailing seven entries are this week and the seven before that are the
/// prior week. Short circuits if fewer than 14 entries are present.
@visibleForTesting
WeeklyInsights computeWeeklyInsights(
  List<DayEntry> days,
  List<MoodEntry> moods,
  {DateTime? now}
) {
  final len = days.length;
  if (len < 14) {
    return const WeeklyInsights(
      daysPracticed: 0,
      minutesThisWeek: 0,
      minutesLastWeek: 0,
      averageMood: null,
    );
  }
  var practiced = 0;
  var thisWeek = 0;
  var lastWeek = 0;
  for (var i = len - 7; i < len; i++) {
    final m = days[i].minutes;
    thisWeek += m;
    if (m > 0) practiced++;
  }
  for (var i = len - 14; i < len - 7; i++) {
    lastWeek += days[i].minutes;
  }
  final cutoff = (now ?? DateTime.now()).subtract(const Duration(days: 7));
  final recentMoods =
      moods.where((e) => e.date.isAfter(cutoff)).toList(growable: false);
  final avgMood = recentMoods.isEmpty
      ? null
      : recentMoods.map((e) => e.mood).reduce((a, b) => a + b) /
          recentMoods.length;
  return WeeklyInsights(
    daysPracticed: practiced,
    minutesThisWeek: thisWeek,
    minutesLastWeek: lastWeek,
    averageMood: avgMood,
  );
}

final weeklyInsightsProvider = Provider<WeeklyInsights>((ref) {
  final progress = ref.watch(progressProvider);
  final moods = ref.watch(moodProvider);
  return computeWeeklyInsights(
    progress.days,
    moods,
    now: ref.read(clockProvider)(),
  );
});
