import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'app.dart';
import 'data/crash_reporter.dart';
import 'data/notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hook the framework + engine error channels *before* any app code runs
  // so faults during init are captured too. The reporter is still the
  // debug stub until a real SDK (Sentry / Crashlytics) is wired in.
  const DebugCrashReporter().install();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Lock-screen + notification-area media controls for the player.
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.serenity.serenity_app.audio',
    androidNotificationChannelName: 'Meditation playback',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );

  await Hive.initFlutter();
  await Hive.openBox<dynamic>('settings');
  await Hive.openBox<dynamic>('progress');

  await NotificationService.init();

  runApp(const ProviderScope(child: SerenityApp()));
}
