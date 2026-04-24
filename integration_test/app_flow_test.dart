import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:serenity_app/features/breathe/breathe_screen.dart';
import 'package:serenity_app/features/breathe/breathe_session_screen.dart';
import 'package:serenity_app/features/home/home_screen.dart';
import 'package:serenity_app/features/library/library_detail_screen.dart';
import 'package:serenity_app/features/library/library_screen.dart';
import 'package:serenity_app/features/player/widgets/timer_ring.dart';
import 'package:serenity_app/features/profile/premium_screen.dart';
import 'package:serenity_app/features/profile/profile_screen.dart';
import 'package:serenity_app/features/profile/progress_screen.dart';
import 'package:serenity_app/features/profile/settings_screen.dart';
import 'package:serenity_app/main.dart' as app;

/// End-to-end screenshot walk.
///
/// The app has infinite animations (aurora, stars, breathing) so we never use
/// `pumpAndSettle`. We drive real time with `runAsync(Future.delayed(...))`
/// and poll for the expected text rather than assuming a fixed wait.
Future<void> _wait(WidgetTester tester, Duration d) async {
  await tester.runAsync<void>(() => Future<void>.delayed(d));
  await tester.pump();
}

/// Wait for any of the text fragments to appear. Polls every 300ms.
Future<void> _waitForFinder(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 12),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (finder.evaluate().isNotEmpty) return;
    await _wait(tester, const Duration(milliseconds: 300));
  }
  throw StateError('Timed out waiting for finder: $finder');
}

Future<void> _capture(WidgetTester tester, String name) async {
  // Let the scene settle on a representative frame first.
  await _wait(tester, const Duration(milliseconds: 500));

  // Emit marker by writing a *dedicated* file then waiting well past
  // filesystem-polling latency. stdout/stderr pipe buffering in `flutter test`
  // was starving the external screenshot grabber — multiple markers flushed
  // in one burst and all captures landed on the final page. A watched file
  // path removes that entire class of bug.
  final marker = File('/tmp/serenity_marker_current');
  marker.writeAsStringSync(name, flush: true);

  // Give the external watcher plenty of time to detect + screenshot.
  await _wait(tester, const Duration(milliseconds: 1600));
}

Future<void> _tapFinder(WidgetTester tester, Finder finder) async {
  await tester.tap(finder.first);
  await _wait(tester, const Duration(milliseconds: 700));
}

Future<void> _tapIcon(WidgetTester tester, IconData icon) async {
  await _tapFinder(tester, find.byIcon(icon));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Hive.initFlutter();
    final settings = await Hive.openBox<dynamic>('settings');
    // The app shell enforces a required medical disclaimer on first
    // shell entry. Pre-acknowledge it here (using the post-migration
    // namespaced key — the legacy key would still be migrated on build()
    // but this harness should mirror a real post-migration install) so
    // the walkthrough stays focused on the main happy-path surfaces
    // instead of a modal gate.
    await settings.put('profile.medicalDisclaimerAcknowledged', true);
  });

  testWidgets('walk the full app flow and screenshot each screen',
      (tester) async {
    app.main();

    // 01 splash — let fonts render, then capture.
    await _wait(tester, const Duration(milliseconds: 800));
    await _capture(tester, '01_splash');

    // 02 onboarding — wait for the splash's Future.delayed to land us there.
    await _waitForFinder(tester, find.byKey(const Key('onboarding-begin')));
    await _capture(tester, '02_onboarding');

    // 03 home
    await _tapFinder(tester, find.byKey(const Key('onboarding-begin')));
    // New: onboarding goals questionnaire sits between splash and home.
    // If it renders, skip through it; a returning user with `onboarded=true`
    // will bypass it and this block is a no-op.
    if (find.byKey(const Key('onboarding-goals-skip')).evaluate().isNotEmpty) {
      await _capture(tester, '02b_onboarding_goals');
      await _tapFinder(
        tester,
        find.byKey(const Key('onboarding-goals-skip')),
      );
    }
    await _waitForFinder(tester, find.byType(HomeScreen));
    await _capture(tester, '03_home');

    // 04 player (paused)
    await _tapFinder(tester, find.byKey(const Key('home-tonight-card')));
    await _waitForFinder(tester, find.byType(TimerRing));
    await _capture(tester, '04_player_paused');

    // 05 player (playing)
    await _tapIcon(tester, LucideIcons.play);
    await _wait(tester, const Duration(seconds: 2));
    await _capture(tester, '05_player_playing');

    // Close player
    await _tapIcon(tester, LucideIcons.x);

    // 06 library
    await _tapIcon(tester, LucideIcons.library);
    await _waitForFinder(tester, find.byType(LibraryScreen));
    await _capture(tester, '06_library');

    // 07 library filtered
    await _tapFinder(tester, find.byKey(const Key('library-chip-sleep')));
    await _capture(tester, '07_library_sleep');

    // 08 library detail
    await _tapFinder(
      tester,
      find.byKey(const Key('library-session-deep-sleep-story')),
    );
    await _waitForFinder(tester, find.byType(LibraryDetailScreen));
    await _capture(tester, '08_library_detail');

    // Back
    await _tapIcon(tester, LucideIcons.chevronLeft);

    // 09 breathe list
    await _tapIcon(tester, LucideIcons.wind);
    await _waitForFinder(tester, find.byType(BreatheScreen));
    await _capture(tester, '09_breathe_list');

    // 10 breathe session ready
    await _tapFinder(
      tester,
      find.byKey(const Key('breathe-technique-box')),
    );
    await _waitForFinder(tester, find.byType(BreatheSessionScreen));
    await _capture(tester, '10_breathe_session_ready');

    // 11 breathe session active
    await _tapIcon(tester, LucideIcons.play);
    await _wait(tester, const Duration(seconds: 2));
    await _capture(tester, '11_breathe_session_active');

    // Close session
    await _tapIcon(tester, LucideIcons.x);

    // 12 profile
    await _tapIcon(tester, LucideIcons.user);
    await _waitForFinder(tester, find.byType(ProfileScreen));
    await _capture(tester, '12_profile');

    // 13 progress
    await _tapIcon(tester, LucideIcons.lineChart);
    await _waitForFinder(tester, find.byType(ProgressScreen));
    await _capture(tester, '13_progress');

    await _tapIcon(tester, LucideIcons.chevronLeft);

    // 14 premium
    await _tapIcon(tester, LucideIcons.crown);
    await _waitForFinder(tester, find.byType(PremiumScreen));
    await _capture(tester, '14_premium');

    await _tapIcon(tester, LucideIcons.x);

    // 15 settings
    await _tapIcon(tester, LucideIcons.settings);
    await _waitForFinder(tester, find.byType(SettingsScreen));
    await _capture(tester, '15_settings');

    // Final sanity — just make sure Material is still there.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
