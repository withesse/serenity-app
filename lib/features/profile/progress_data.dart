import 'package:flutter/foundation.dart';

@immutable
class DayEntry {
  const DayEntry(this.date, this.minutes);
  final DateTime date;
  final int minutes;
}

/// What the achievement measures — drives the unit label ("sessions" /
/// "days" / "minutes") on the detail screen and the target-copy phrasing.
enum AchievementMetric { sessions, streak, minutes }

@immutable
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.metric,
    required this.target,
    required this.progress,
  });

  final String id;
  final String title;
  final String subtitle;
  final AchievementMetric metric;
  final int target;
  final int progress;

  bool get unlocked => progress >= target;
  double get percent =>
      target == 0 ? 1.0 : (progress / target).clamp(0.0, 1.0);
}

@immutable
class ProgressSnapshot {
  const ProgressSnapshot({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalMinutes,
    required this.sessionsCompleted,
    required this.days,
    required this.achievements,
  });

  final int currentStreak;
  final int longestStreak;
  final int totalMinutes;
  final int sessionsCompleted;
  final List<DayEntry> days; // Most recent 35 days, oldest first.
  final List<Achievement> achievements;
}

/// Deterministic mock data. Returns a consistent snapshot across builds by
/// seeding on a fixed anchor date rather than DateTime.now() — this keeps
/// widget tests stable and the screen visually reproducible during review.
ProgressSnapshot mockProgress() {
  final anchor = DateTime(2026, 4, 20);
  final days = <DayEntry>[];
  // Varied but believable pattern — heavier recently, a couple of off days.
  const seed = [
    0, 8, 5, 12, 10, 15, 6, 18, 0, 22,
    14, 10, 8, 14, 0, 0, 12, 6, 18, 10,
    12, 15, 18, 10, 14, 20, 8, 10, 14,
    12, 18, 10, 20, 8, 15, 14,
  ];
  for (var i = 34; i >= 0; i--) {
    final date = anchor.subtract(Duration(days: i));
    days.add(DayEntry(date, seed[i]));
  }

  return ProgressSnapshot(
    currentStreak: 7,
    longestStreak: 21,
    totalMinutes: days.fold(0, (a, d) => a + d.minutes),
    sessionsCompleted: 42,
    days: days,
    achievements: const [
      Achievement(
        id: 'first-breath',
        title: 'First Breath',
        subtitle: 'Completed your first session',
        metric: AchievementMetric.sessions,
        target: 1,
        progress: 42,
      ),
      Achievement(
        id: 'seven-nights',
        title: 'Seven Nights',
        subtitle: '7-day streak',
        metric: AchievementMetric.streak,
        target: 7,
        progress: 7,
      ),
      Achievement(
        id: 'night-watcher',
        title: 'Night Watcher',
        subtitle: '10 sessions completed',
        metric: AchievementMetric.sessions,
        target: 10,
        progress: 42,
      ),
      Achievement(
        id: 'deep-well',
        title: 'Deep Well',
        subtitle: '500 minutes meditated',
        metric: AchievementMetric.minutes,
        target: 500,
        progress: 380,
      ),
      Achievement(
        id: 'constellation',
        title: 'Constellation',
        subtitle: '30-day streak',
        metric: AchievementMetric.streak,
        target: 30,
        progress: 7,
      ),
    ],
  );
}
