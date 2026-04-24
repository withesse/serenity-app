import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:serenity_app/data/insights.dart';
import 'package:serenity_app/data/library_repository.dart';
import 'package:serenity_app/data/mood_store.dart';
import 'package:serenity_app/data/progress_store.dart';
import 'package:serenity_app/features/breathe/breathing_techniques.dart';
import 'package:serenity_app/features/legal/legal_screen.dart';
import 'package:serenity_app/features/library/library_data.dart';
import 'package:serenity_app/features/player/player_controller.dart';
import 'package:serenity_app/features/player/widgets/timer_ring.dart';
import 'package:serenity_app/features/profile/progress_data.dart';

void main() {
  group('tonightRecommendation', () {
    test('picks sleep at night', () {
      final r = tonightRecommendation(
        now: DateTime(2026, 4, 22, 23, 30),
      );
      expect(r.category, LibraryCategory.sleep);
    });

    test('picks morning in the morning', () {
      final r = tonightRecommendation(
        now: DateTime(2026, 4, 22, 7),
      );
      expect(r.category, LibraryCategory.morning);
    });

    test('prefers user goals over hour when they differ', () {
      // 14:00 would normally suggest focus; a user whose only goal is
      // sleep should still see a sleep session.
      final r = tonightRecommendation(
        now: DateTime(2026, 4, 22, 14),
        goals: {LibraryCategory.sleep},
      );
      expect(r.category, LibraryCategory.sleep);
    });

    test('respects hour when it matches one of multiple goals', () {
      final r = tonightRecommendation(
        now: DateTime(2026, 4, 22, 14),
        goals: {LibraryCategory.focus, LibraryCategory.sleep},
      );
      expect(r.category, LibraryCategory.focus);
    });
  });

  group('LibrarySession.localized', () {
    test('returns English when locale is en', () {
      final s = findSession('midnight-harbour') ??
          findSession('deep-sleep-story')!;
      final t = s.localized(const Locale('en'));
      expect(t.title, s.title);
    });

    test('returns Chinese translation when locale is zh', () {
      final s = findSession('deep-sleep-story')!;
      final t = s.localized(const Locale('zh'));
      expect(t.title, '午夜港湾');
      expect(t.tagline, contains('深眠'));
    });

    test('falls back to English for missing zh entry', () {
      final s = LibrarySession(
        id: 'not-translated',
        title: 'Raw',
        narrator: 'Anon',
        duration: const Duration(minutes: 5),
        category: LibraryCategory.focus,
        tagline: 'Plain',
        gradient: const [Color(0xFF000000), Color(0xFFFFFFFF)],
      );
      final t = s.localized(const Locale('zh'));
      expect(t.title, 'Raw');
    });
  });

  group('BreathingTechnique.localized', () {
    test('returns English for en, zh override for zh, and English for null locale', () {
      final technique =
          breathingTechniques.firstWhere((t) => t.id == 'four-seven-eight');

      final english = technique.localized(const Locale('en'));
      final chinese = technique.localized(const Locale('zh'));
      final fallback = technique.localized(null);

      expect(english.name, '4-7-8 Relaxing');
      expect(english.tagline, 'Slow the pulse, invite sleep.');
      expect(chinese.name, '4-7-8 呼吸');
      expect(chinese.tagline, '放慢心跳，邀请睡意。');
      expect(fallback.name, '4-7-8 Relaxing');
      expect(fallback.tagline, 'Slow the pulse, invite sleep.');
    });
  });

  group('Legal copy localization', () {
    test('returns zh sections for zh locale and English fallback otherwise', () {
      final privacyZh = privacySectionsFor(const Locale('zh'));
      final termsZh = termsSectionsFor(const Locale('zh'));

      expect(privacyZh.first.heading, '我们收集什么信息');
      expect(termsZh.first.heading, '非医疗建议');

      expect(
        privacySectionsFor(null).first.heading,
        'What we collect',
      );
      expect(
        privacySectionsFor(const Locale('en')).first.heading,
        'What we collect',
      );
      expect(
        privacySectionsFor(const Locale('fr')).first.heading,
        'What we collect',
      );
      expect(
        termsSectionsFor(const Locale('fr')).first.heading,
        'Not medical advice',
      );
    });
  });

  group('StaticLibraryRepository', () {
    const repo = StaticLibraryRepository();

    test('byCategory filters as expected', () {
      final sleep = repo.byCategory(LibraryCategory.sleep);
      expect(sleep, isNotEmpty);
      expect(sleep.every((s) => s.category == LibraryCategory.sleep), isTrue);
    });

    test('byCategory all returns everything', () {
      expect(repo.byCategory(LibraryCategory.all).length,
          repo.all().length);
    });

    test('related excludes the seed session and caps', () {
      final seed = repo.all().first;
      final related = repo.related(seed, max: 2);
      expect(related.length, lessThanOrEqualTo(2));
      expect(related.any((s) => s.id == seed.id), isFalse);
    });

    test('findById returns null for unknown id', () {
      expect(repo.findById('does-not-exist'), isNull);
    });
  });

  group('MoodEntry', () {
    test('roundtrips through toMap/fromMap', () {
      final entry = MoodEntry(
        date: DateTime(2026, 4, 22),
        mood: 4,
        sessionId: 'box',
      );
      final roundtripped = MoodEntry.fromMap(entry.toMap());
      expect(roundtripped, isNotNull);
      expect(roundtripped!.mood, 4);
      expect(roundtripped.sessionId, 'box');
      expect(roundtripped.date.year, 2026);
    });

    test('clamps mood to 1..5', () {
      final e = MoodEntry.fromMap({'date': '2026-04-22', 'mood': 99});
      expect(e?.mood, 5);
    });

    test('returns null for malformed maps', () {
      expect(MoodEntry.fromMap('nope'), isNull);
      expect(MoodEntry.fromMap({'date': 123}), isNull);
    });
  });

  group('Achievement.percent', () {
    test('caps at 1.0 even when progress exceeds target', () {
      const a = Achievement(
        id: 'night-watcher',
        title: 'Night Watcher',
        subtitle: '10 sessions completed',
        metric: AchievementMetric.sessions,
        target: 10,
        progress: 42,
      );
      expect(a.unlocked, isTrue);
      expect(a.percent, 1.0);
    });

    test('is 0 when nothing achieved yet', () {
      const a = Achievement(
        id: 'constellation',
        title: 'Constellation',
        subtitle: '30-day streak',
        metric: AchievementMetric.streak,
        target: 30,
        progress: 0,
      );
      expect(a.unlocked, isFalse);
      expect(a.percent, 0);
    });
  });

  group('computeWeeklyInsights', () {
    List<DayEntry> buildDays(List<int> minutes, {DateTime? end}) {
      final anchor = end ?? DateTime(2026, 4, 23);
      return [
        for (var i = 0; i < minutes.length; i++)
          DayEntry(
            DateTime(anchor.year, anchor.month, anchor.day)
                .subtract(Duration(days: minutes.length - 1 - i)),
            minutes[i],
          ),
      ];
    }

    test('returns zeroed insights for empty inputs', () {
      final insights = computeWeeklyInsights(
        const [],
        const [],
        now: DateTime(2026, 4, 23),
      );

      expect(insights.daysPracticed, 0);
      expect(insights.minutesThisWeek, 0);
      expect(insights.minutesLastWeek, 0);
      expect(insights.minutesDelta, 0);
      expect(insights.averageMood, isNull);
    });

    test('treats fourteen zero-minute days as no practice in either week', () {
      final insights = computeWeeklyInsights(
        buildDays(List<int>.filled(14, 0)),
        const [],
        now: DateTime(2026, 4, 23),
      );

      expect(insights.daysPracticed, 0);
      expect(insights.minutesThisWeek, 0);
      expect(insights.minutesLastWeek, 0);
      expect(insights.minutesDelta, 0);
      expect(insights.averageMood, isNull);
    });

    test('counts current-week practiced days and positive delta over empty prior week', () {
      final insights = computeWeeklyInsights(
        buildDays(const [0, 0, 0, 0, 0, 0, 0, 10, 0, 8, 0, 0, 12, 0]),
        const [],
        now: DateTime(2026, 4, 23),
      );

      expect(insights.daysPracticed, 3);
      expect(insights.minutesThisWeek, 30);
      expect(insights.minutesLastWeek, 0);
      expect(insights.minutesDelta, 30);
    });

    test('reports a negative delta when the prior week had more minutes', () {
      final insights = computeWeeklyInsights(
        buildDays(const [10, 10, 10, 0, 0, 0, 0, 5, 5, 0, 0, 0, 0, 0]),
        const [],
        now: DateTime(2026, 4, 23),
      );

      expect(insights.minutesThisWeek, 10);
      expect(insights.minutesLastWeek, 30);
      expect(insights.minutesDelta, -20);
    });

    test('averages only moods from the last seven days', () {
      final insights = computeWeeklyInsights(
        buildDays(List<int>.filled(14, 0)),
        [
          MoodEntry(date: DateTime(2026, 4, 23), mood: 5),
          MoodEntry(date: DateTime(2026, 4, 20), mood: 3),
          MoodEntry(date: DateTime(2026, 4, 10), mood: 1),
        ],
        now: DateTime(2026, 4, 23),
      );

      expect(insights.averageMood, 4);
    });
  });

  group('ProgressController ISO week logic', () {
    test('matches ISO week-year at year boundaries and normal dates', () {
      expect(
        ProgressController.isoWeekFor(DateTime(2021, 1, 1)),
        '2020-W53',
      );
      expect(
        ProgressController.isoWeekFor(DateTime(2016, 1, 1)),
        '2015-W53',
      );
      expect(
        ProgressController.isoWeekFor(DateTime(2026, 1, 1)),
        '2026-W01',
      );
      expect(
        ProgressController.isoWeekFor(DateTime(2027, 1, 1)),
        '2026-W53',
      );
      expect(
        ProgressController.isoWeekFor(DateTime(2026, 6, 18)),
        '2026-W25',
      );
      expect(
        ProgressController.isoWeekFor(DateTime(2020, 1, 2)),
        '2020-W01',
      );
      expect(
        ProgressController.isoWeekFor(DateTime(2020, 12, 31)),
        '2020-W53',
      );
      expect(
        ProgressController.isoWeekFor(DateTime(2015, 12, 31)),
        '2015-W53',
      );
    });
  });

  group('PlayerController interruption wiring', () {
    test('relies on just_audio interruptions and tracks noisy subscription disposal', () {
      final source =
          File('lib/features/player/player_controller.dart').readAsStringSync();

      expect(source, isNot(contains('interruptionEventStream.listen')));
      expect(
        source,
        contains(
          '_subs.add(session.becomingNoisyEventStream.listen((_) => _audio.pause()));',
        ),
      );
    });
  });

  group('Player playback duration resolution', () {
    test('keeps the session duration when a loaded asset looks like the placeholder', () {
      expect(
        resolvedPlaybackDuration(
          const Duration(minutes: 12),
          const Duration(minutes: 10),
        ),
        const Duration(minutes: 12),
      );
    });

    test('accepts a loaded asset duration when it matches the session within epsilon', () {
      expect(
        resolvedPlaybackDuration(
          const Duration(minutes: 12),
          const Duration(minutes: 12, seconds: 1),
        ),
        const Duration(minutes: 12, seconds: 1),
      );
    });
  });

  group('Player audio asset selection', () {
    test('prefers locale-tagged zh asset and falls back to unversioned for null locale', () {
      expect(audioAssetFor('foo', const Locale('zh')), 'assets/audio/foo.zh.mp3');
      expect(audioAssetFor('foo', const Locale('en')), 'assets/audio/foo.en.mp3');
      expect(audioAssetFor('foo', null), 'assets/audio/foo.mp3');
      expect(audioAssetFor('foo', const Locale('fr')), 'assets/audio/foo.mp3');
    });
  });

  group('Player session-switch minute tracking', () {
    test('resets last-tracked minute when loading a different session', () {
      final controllerSource =
          File('lib/features/player/player_controller.dart').readAsStringSync();

      // loadSession is now the single audio-load entry point; _loadDefault
      // was removed once the neutral bootstrap made it dead code. The
      // reset guard must live inside loadSession.
      expect(
        controllerSource,
        contains('if (state.sessionId != session.id) {\n      _lastTrackedMinute = 0;'),
      );
      expect(controllerSource, isNot(contains('_loadDefault')));
    });
  });

  group('TimerRing semantics', () {
    test('formats remaining time, total duration, and percent complete', () {
      expect(
        timerRingSemanticsLabel(Duration.zero, const Duration(minutes: 10)),
        '10:00 remaining of 10:00, 0% complete',
      );
      expect(
        timerRingSemanticsLabel(
          const Duration(minutes: 5),
          const Duration(minutes: 10),
        ),
        '5:00 remaining of 10:00, 50% complete',
      );
      expect(
        timerRingSemanticsLabel(
          const Duration(minutes: 10),
          const Duration(minutes: 10),
        ),
        '0:00 remaining of 10:00, 100% complete',
      );
    });
  });
}
