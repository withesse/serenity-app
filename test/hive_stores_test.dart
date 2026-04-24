import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:serenity_app/data/downloads_store.dart';
import 'package:serenity_app/data/favourites_store.dart';
import 'package:serenity_app/data/mood_store.dart';
import 'package:serenity_app/data/profile_store.dart';
import 'package:serenity_app/data/progress_store.dart';
import 'package:serenity_app/data/settings_store.dart';
import 'package:serenity_app/features/library/library_data.dart';

/// Fresh container per test — otherwise notifier state from the previous
/// assertion leaks across cases via the long-lived providers.
ProviderContainer _container() => ProviderContainer();

Future<T> _withLatePeriodicTick<T>(Future<T> Function() body) {
  return runZoned(
    body,
    zoneSpecification: ZoneSpecification(
      createPeriodicTimer: (self, parent, zone, duration, callback) {
        final timer = _LateTickTimer(zone, duration, callback);
        timer.start();
        return timer;
      },
    ),
  );
}

class _LateTickTimer implements Timer {
  _LateTickTimer(this._zone, this._duration, this._callback);

  final Zone _zone;
  final Duration _duration;
  final void Function(Timer) _callback;

  var _tick = 0;
  var _active = true;
  var _lateTickScheduled = false;

  void start() => _scheduleTick(_duration);

  void _scheduleTick(Duration delay) {
    Future<void>.delayed(delay, () {
      if (!_active) return;
      _tick += 1;
      _zone.runUnaryGuarded(_callback, this);
      if (_active) {
        _scheduleTick(_duration);
      }
    });
  }

  @override
  bool get isActive => _active;

  @override
  int get tick => _tick;

  @override
  void cancel() {
    if (!_active) return;
    _active = false;
    if (_lateTickScheduled) return;
    _lateTickScheduled = true;
    Future<void>.delayed(const Duration(milliseconds: 10), () {
      _tick += 1;
      _zone.runUnaryGuarded(_callback, this);
    });
  }
}

Future<void> _resetBox(String name) async {
  if (Hive.isBoxOpen(name)) await Hive.box<dynamic>(name).clear();
  await Hive.openBox<dynamic>(name);
  await Hive.box<dynamic>(name).clear();
}

void main() {
  late Directory tmp;

  setUpAll(() async {
    tmp = await Directory.systemTemp.createTemp('serenity-test-');
    Hive.init(tmp.path);
    await Hive.openBox<dynamic>('settings');
    await Hive.openBox<dynamic>('progress');
  });

  tearDownAll(() async {
    await Hive.close();
    await tmp.delete(recursive: true);
  });

  setUp(() async {
    await _resetBox('settings');
    await _resetBox('progress');
  });

  group('FavouritesController', () {
    test('toggle adds then removes', () async {
      final c = _container();
      final notifier = c.read(favouritesProvider.notifier);
      await notifier.toggle('midnight-harbour');
      expect(c.read(favouritesProvider), contains('midnight-harbour'));
      await notifier.toggle('midnight-harbour');
      expect(c.read(favouritesProvider), isEmpty);
      c.dispose();
    });

    test('persists across container restart', () async {
      final first = _container();
      await first.read(favouritesProvider.notifier).toggle('forest-at-dusk');
      first.dispose();

      final second = _container();
      expect(second.read(favouritesProvider), contains('forest-at-dusk'));
      second.dispose();
    });

    test('wipeAll clears persisted favourites', () async {
      final c = _container();
      final notifier = c.read(favouritesProvider.notifier);

      await notifier.toggle('forest-at-dusk');
      expect(c.read(favouritesProvider), isNotEmpty);

      await notifier.wipeAll();

      expect(c.read(favouritesProvider), isEmpty);
      expect(Hive.box<dynamic>('settings').get('favourites'), isNull);
      c.dispose();
    });
  });

  group('MoodController', () {
    test('record appends an entry', () async {
      final c = _container();
      await c.read(moodProvider.notifier).record(4, sessionId: 'box');
      final entries = c.read(moodProvider);
      expect(entries, hasLength(1));
      expect(entries.first.mood, 4);
      expect(entries.first.sessionId, 'box');
      c.dispose();
    });

    test('recent() omits older entries', () async {
      final c = _container();
      await c.read(moodProvider.notifier).record(3);
      final recent = c.read(moodProvider.notifier).recent(7);
      expect(recent, hasLength(1));
      c.dispose();
    });
  });

  group('ProfileController', () {
    test('setGoals filters out "all" and persists', () async {
      final c = _container();
      final notifier = c.read(profileProvider.notifier);
      await notifier.setGoals({
        LibraryCategory.sleep,
        LibraryCategory.all, // should be stripped
      });
      expect(c.read(profileProvider).goals, {LibraryCategory.sleep});

      c.dispose();
      final c2 = _container();
      expect(c2.read(profileProvider).goals, {LibraryCategory.sleep});
      c2.dispose();
    });

    test('markOnboarded flips the flag', () async {
      final c = _container();
      expect(c.read(profileProvider).onboarded, isFalse);
      await c.read(profileProvider.notifier).markOnboarded();
      expect(c.read(profileProvider).onboarded, isTrue);
      c.dispose();
    });

    test('medical disclaimer acknowledgement defaults false and persists once set', () async {
      final c = _container();
      expect(c.read(profileProvider).medicalDisclaimerAcknowledged, isFalse);
      await c.read(profileProvider.notifier).acknowledgeMedicalDisclaimer();
      expect(c.read(profileProvider).medicalDisclaimerAcknowledged, isTrue);

      c.dispose();
      final c2 = _container();
      expect(c2.read(profileProvider).medicalDisclaimerAcknowledged, isTrue);
      c2.dispose();
    });

    test('build reads persisted onboarding and disclaimer flags from settings', () async {
      await Hive.box<dynamic>('settings').putAll({
        'onboarded': true,
        'medicalDisclaimerAcknowledged': false,
      });

      final c = _container();
      expect(c.read(profileProvider).onboarded, isTrue);
      expect(c.read(profileProvider).medicalDisclaimerAcknowledged, isFalse);
      c.dispose();
    });

    test('wipeAccountData resets goals, onboarding, and disclaimer flags', () async {
      final c = _container();
      final notifier = c.read(profileProvider.notifier);

      await notifier.setGoals({LibraryCategory.sleep, LibraryCategory.focus});
      await notifier.markOnboarded();
      await notifier.acknowledgeMedicalDisclaimer();
      expect(c.read(profileProvider).goals, isNotEmpty);
      expect(c.read(profileProvider).onboarded, isTrue);
      expect(c.read(profileProvider).medicalDisclaimerAcknowledged, isTrue);

      await notifier.wipeAccountData();

      expect(c.read(profileProvider).goals, isEmpty);
      expect(c.read(profileProvider).onboarded, isFalse);
      expect(c.read(profileProvider).medicalDisclaimerAcknowledged, isFalse);
      c.dispose();
    });
  });

  group('SettingsController', () {
    test('wipeUserPreferences restores default settings values', () async {
      final c = _container();
      final notifier = c.read(settingsProvider.notifier);

      await notifier.setHapticFeedback(false);
      await notifier.setBackgroundAudio(false);
      await notifier.setDownloadOverWifi(false);
      await notifier.setLanguage(AppLanguage.zh);
      await notifier.setThemeMode(AppThemeMode.dark);
      // Write via the namespaced keys SettingsController now uses. Old
      // unprefixed keys are migrated on build() but are no longer the
      // active slot — tests should target the new ones directly.
      await Hive.box<dynamic>('settings').put('settings.dailyReminder', false);
      await Hive.box<dynamic>('settings').put('settings.dailyReminderTime', '08:15');
      await Hive.box<dynamic>('settings').put('settings.sleepReminder', false);
      await Hive.box<dynamic>('settings').put('settings.sleepReminderTime', '23:45');
      await Hive.box<dynamic>('settings').put('profile.goals', ['sleep']);

      await notifier.wipeUserPreferences();

      final state = c.read(settingsProvider);
      expect(state.dailyReminder, isTrue);
      expect(state.dailyReminderTime, const TimeOfDay(hour: 21, minute: 0));
      expect(state.sleepReminder, isTrue);
      expect(state.sleepReminderTime, const TimeOfDay(hour: 22, minute: 30));
      expect(state.hapticFeedback, isTrue);
      expect(state.backgroundAudio, isTrue);
      expect(state.downloadOverWifi, isTrue);
      expect(state.language, AppLanguage.system);
      expect(state.themeMode, AppThemeMode.system);
      expect(Hive.box<dynamic>('settings').get('profileGoals'), isNull);
      c.dispose();
    });
  });

  group('Auto theme clock', () {
    test('auto-disposes and clears its timer after leaving auto mode', () async {
      await Hive.box<dynamic>('settings').put('themeMode', AppThemeMode.auto.name);

      final c = _container();
      addTearDown(c.dispose);

      final themeSub =
          c.listen(themeModeProvider, (_, next) {}, fireImmediately: true);
      addTearDown(themeSub.close);

      final clock = c.read(autoThemeClockProvider.notifier);
      expect(c.read(settingsProvider).themeMode, AppThemeMode.auto);
      expect(c.exists(autoThemeClockProvider), isTrue);
      expect(clock.debugTimer, isNotNull);
      expect(clock.debugTimer!.isActive, isTrue);

      await c.read(settingsProvider.notifier).setThemeMode(AppThemeMode.dark);
      await c.pump();

      expect(c.read(settingsProvider).themeMode, AppThemeMode.dark);
      expect(c.exists(autoThemeClockProvider), isFalse);
      expect(clock.debugTimer, isNull);

      c.read(themeModeProvider);
      c.read(themeModeProvider);
      expect(c.exists(autoThemeClockProvider), isFalse);
    });
  });

  group('DownloadsController', () {
    test('start progresses through to completion', () async {
      final c = _container();
      final notifier = c.read(downloadsProvider.notifier);
      await notifier.start('deep-work');

      // Simulator ticks every 100ms for 30 ticks ≈ 3s; give it 4s of slack.
      await Future.delayed(const Duration(seconds: 4));

      final entry = c.read(downloadEntryProvider('deep-work'));
      expect(entry.status, DownloadStatus.completed);
      expect(entry.progress, 1.0);
      c.dispose();
    });

    test('cancel stops an in-flight download', () async {
      final c = _container();
      final notifier = c.read(downloadsProvider.notifier);
      await notifier.start('focus-flow');
      await Future.delayed(const Duration(milliseconds: 250));
      await notifier.cancel('focus-flow');

      final entry = c.read(downloadEntryProvider('focus-flow'));
      expect(entry.status, DownloadStatus.none);
      c.dispose();
    });

    test('cancel ignores a stale tick that lands after removal', () async {
      await _withLatePeriodicTick(() async {
        final c = _container();
        addTearDown(c.dispose);
        final notifier = c.read(downloadsProvider.notifier);

        await notifier.start('focus-flow');
        await Future.delayed(const Duration(milliseconds: 120));

        final activeEntry = c.read(downloadEntryProvider('focus-flow'));
        expect(activeEntry.status, DownloadStatus.downloading);
        expect(activeEntry.progress, greaterThan(0));

        await notifier.cancel('focus-flow');
        expect(c.read(downloadsProvider).containsKey('focus-flow'), isFalse);
        expect(c.read(downloadEntryProvider('focus-flow')).progress, 0);

        await Future.delayed(const Duration(milliseconds: 50));

        expect(c.read(downloadsProvider).containsKey('focus-flow'), isFalse);
        final entry = c.read(downloadEntryProvider('focus-flow'));
        expect(entry.status, DownloadStatus.none);
        expect(entry.progress, 0);
      });
    });

    test('unrelated sessions do not rebuild on another session progress', () async {
      final c = _container();
      addTearDown(c.dispose);

      var rebuilds = 0;
      final sub = c.listen(
        downloadEntryProvider('midnight-harbour'),
        (_, next) => rebuilds += 1,
        fireImmediately: true,
      );
      addTearDown(sub.close);

      await c.read(downloadsProvider.notifier).start('deep-work');
      await Future.delayed(const Duration(milliseconds: 350));

      expect(rebuilds, 1);
    });

    test('wipeAll clears downloads state and persistence', () async {
      final c = _container();
      final notifier = c.read(downloadsProvider.notifier);

      await notifier.start('focus-flow');
      await Future.delayed(const Duration(milliseconds: 150));
      expect(c.read(downloadsProvider), isNotEmpty);

      await notifier.wipeAll();

      expect(c.read(downloadsProvider), isEmpty);
      expect(Hive.box<dynamic>('settings').get('downloads'), isNull);
      expect(c.read(downloadEntryProvider('focus-flow')).status, DownloadStatus.none);
      c.dispose();
    });
  });

  group('ProgressController.recordSession', () {
    test('records minutes and increments streak on first session', () async {
      final c = _container();
      await c.read(progressProvider.notifier).recordSession(10);
      final state = c.read(progressProvider);
      expect(state.currentStreak, greaterThanOrEqualTo(1));
      expect(state.sessionsCompleted, greaterThanOrEqualTo(1));
      c.dispose();
    });

    test('same-day second record does not bump streak twice', () async {
      final c = _container();
      final notifier = c.read(progressProvider.notifier);
      await notifier.recordSession(5);
      final afterFirst = c.read(progressProvider).currentStreak;
      await notifier.recordSession(5);
      final afterSecond = c.read(progressProvider).currentStreak;
      expect(afterSecond, afterFirst);
      c.dispose();
    });

    test('rolls stale day window forward and accumulates in today slot', () async {
      final today = DateTime.now();
      final twoDaysAgo = today.subtract(const Duration(days: 2));
      await Hive.box<dynamic>('progress').putAll({
        'seeded': true,
        'daysMinutes': List<int>.generate(35, (i) => i + 1),
        'currentStreak': 4,
        'longestStreak': 9,
        'totalMinutes': 100,
        'sessionsCompleted': 8,
        'lastSessionDate':
            '${twoDaysAgo.year.toString().padLeft(4, '0')}-'
            '${twoDaysAgo.month.toString().padLeft(2, '0')}-'
            '${twoDaysAgo.day.toString().padLeft(2, '0')}',
      });

      final c = _container();
      final notifier = c.read(progressProvider.notifier);

      await notifier.recordSession(5);
      await notifier.recordSession(7);

      final state = c.read(progressProvider);
      expect(state.days[state.days.length - 3].minutes, 35);
      expect(state.days[state.days.length - 2].minutes, 0);
      expect(state.days.last.minutes, 12);
      c.dispose();
    });

    test('freeze is available on a fresh install', () async {
      final c = _container();
      expect(c.read(progressProvider).freezeAvailable, isTrue);
      c.dispose();
    });
  });
}
