import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'analytics.dart';
import 'clock.dart';

/// Post-session mood check-in. Persisted in the existing `progress` Hive box
/// under the `moods` key as a list of plain maps so no generated adapter is
/// required. Each entry has the session's finish date (yyyy-MM-dd), a mood
/// score 1..5 (1 = terrible, 5 = amazing), and an optional session id that
/// links the rating back to a library session or breathing technique.
@immutable
class MoodEntry {
  const MoodEntry({
    required this.date,
    required this.mood,
    this.sessionId,
  });

  final DateTime date;
  final int mood;
  final String? sessionId;

  Map<String, dynamic> toMap() => {
        'date': _isoDay(date),
        'mood': mood,
        if (sessionId != null) 'sessionId': sessionId,
      };

  static MoodEntry? fromMap(dynamic raw) {
    if (raw is! Map) return null;
    final date = raw['date'];
    final mood = raw['mood'];
    if (date is! String || mood is! int) return null;
    return MoodEntry(
      date: DateTime.tryParse(date) ?? DateTime.now(),
      mood: mood.clamp(1, 5),
      sessionId: raw['sessionId'] as String?,
    );
  }
}

String _isoDay(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

class MoodController extends Notifier<List<MoodEntry>> {
  static const _boxName = 'progress';
  static const _key = 'moods';

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  @override
  List<MoodEntry> build() {
    final raw = _box.get(_key) as List?;
    if (raw == null) return const [];
    return raw
        .map(MoodEntry.fromMap)
        .whereType<MoodEntry>()
        .toList(growable: false);
  }

  Future<void> record(int mood, {String? sessionId}) async {
    final entry = MoodEntry(
      date: ref.read(clockProvider)(),
      mood: mood.clamp(1, 5),
      sessionId: sessionId,
    );
    final next = [...state, entry];
    await _box.put(_key, next.map((e) => e.toMap()).toList());
    state = next;
    await ref.read(analyticsProvider).track(
      AnalyticsEvents.moodRecorded,
      {'mood': entry.mood, 'sessionId': sessionId},
    );
  }

  /// Most recent [days] of check-ins, oldest → newest. Days without a
  /// check-in are omitted; if a day has multiple entries, the latest wins.
  List<MoodEntry> recent(int days) {
    if (state.isEmpty) return const [];
    final cutoff = ref.read(clockProvider)().subtract(Duration(days: days - 1));
    final cutoffDay = DateTime(cutoff.year, cutoff.month, cutoff.day);
    final byDay = <String, MoodEntry>{};
    for (final e in state) {
      if (e.date.isBefore(cutoffDay)) continue;
      byDay[_isoDay(e.date)] = e;
    }
    final keys = byDay.keys.toList()..sort();
    return [for (final k in keys) byDay[k]!];
  }
}

final moodProvider =
    NotifierProvider<MoodController, List<MoodEntry>>(MoodController.new);
