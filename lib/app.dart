import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/settings_store.dart';
import 'data/widget_bridge.dart';
import 'l10n/app_localizations.dart';

class SerenityApp extends ConsumerStatefulWidget {
  const SerenityApp({super.key});

  @override
  ConsumerState<SerenityApp> createState() => _SerenityAppState();
}

class _SerenityAppState extends ConsumerState<SerenityApp> {
  // iOS/Android suspend the app (and our auto-theme timer) when backgrounded.
  // On resume, force the clock provider to re-read `now` so we snap to the
  // correct theme if we crossed a dawn/dusk boundary while asleep.
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        if (ref.read(settingsProvider).themeMode == AppThemeMode.auto) {
          ref.read(autoThemeClockProvider.notifier).resume();
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    // Side-effect only — pushes streak / tonight session to the iOS
    // Widget's App Group whenever progress changes.
    ref.watch(widgetStateSyncProvider);
    return MaterialApp.router(
      title: 'Serenity',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      // Respect the user's OS text-size setting, but clamp the range so our
      // bespoke layouts (timer ring, breathing circle, bento cards) don't
      // overflow at XXL accessibility sizes.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final clamped = mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.3);
        return MediaQuery(
          data: mq.copyWith(textScaler: clamped),
          child: child!,
        );
      },
    );
  }
}
