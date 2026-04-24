import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:serenity_app/core/theme/app_palette.dart';
import 'package:serenity_app/core/theme/app_spacing.dart';
import 'package:serenity_app/core/widgets/states.dart';
import 'package:serenity_app/data/auth_store.dart';
import 'package:serenity_app/data/iap_store.dart';
import 'package:serenity_app/data/profile_store.dart';
import 'package:serenity_app/data/progress_store.dart';
import 'package:serenity_app/data/settings_store.dart';
import 'package:serenity_app/features/library/library_data.dart';
import 'package:serenity_app/features/player/player_controller.dart';
import 'package:serenity_app/features/profile/about_screen.dart';
import 'package:serenity_app/features/profile/credits_screen.dart';
import 'package:serenity_app/features/profile/help_screen.dart';
import 'package:serenity_app/features/profile/medical_disclaimer_dialog.dart';
import 'package:serenity_app/features/profile/profile_screen.dart';
import 'package:serenity_app/features/profile/settings_screen.dart';
import 'package:serenity_app/l10n/app_localizations.dart';

class _FakeProfileController extends ProfileController {
  _FakeProfileController(this._initial);

  final ProfileState _initial;

  @override
  ProfileState build() => _initial;

  @override
  Future<void> acknowledgeMedicalDisclaimer() async {
    state = state.copyWith(medicalDisclaimerAcknowledged: true);
  }
}

class _FakeProgressController extends ProgressController {
  _FakeProgressController(this._initial);

  final ProgressState _initial;

  @override
  ProgressState build() => _initial;
}

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._initial);

  final AuthState _initial;

  @override
  AuthState build() => _initial;
}

class _FakeIapController extends IapController {
  _FakeIapController(this._initial);

  final IapState _initial;

  @override
  IapState build() => _initial;
}

class _FakeSettingsController extends SettingsController {
  _FakeSettingsController(this._initial);

  final SettingsState _initial;

  @override
  SettingsState build() => _initial;
}

const _testProgressState = ProgressState(
  currentStreak: 7,
  longestStreak: 21,
  totalMinutes: 120,
  sessionsCompleted: 12,
  days: [],
  achievements: [],
  freezeAvailable: true,
);

const _testAuthState = AuthState(
  user: AuthUser(
    id: 'user-1',
    email: 'luna@serenity.app',
    displayName: 'Luna',
  ),
  busy: false,
);

const _testIapState = IapState(
  available: false,
  products: [],
  purchasing: false,
  isPremium: false,
);

const _testSettingsState = SettingsState(
  dailyReminder: true,
  dailyReminderTime: TimeOfDay(hour: 21, minute: 0),
  sleepReminder: true,
  sleepReminderTime: TimeOfDay(hour: 22, minute: 30),
  hapticFeedback: true,
  backgroundAudio: true,
  downloadOverWifi: true,
  language: AppLanguage.system,
  themeMode: AppThemeMode.system,
);

ProviderContainer _profileContainer() {
  return ProviderContainer(
    overrides: [
      progressProvider.overrideWith(
        () => _FakeProgressController(_testProgressState),
      ),
      authProvider.overrideWith(
        () => _FakeAuthController(_testAuthState),
      ),
      iapProvider.overrideWith(
        () => _FakeIapController(_testIapState),
      ),
    ],
  );
}

ProviderContainer _settingsContainer() {
  return ProviderContainer(
    overrides: [
      settingsProvider.overrideWith(
        () => _FakeSettingsController(_testSettingsState),
      ),
      authProvider.overrideWith(
        () => _FakeAuthController(_testAuthState),
      ),
      iapProvider.overrideWith(
        () => _FakeIapController(_testIapState),
      ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Palette tokens are wired up', () {
    expect(AppPalette.night.skyGradient, hasLength(3));
    expect(AppPalette.dawn.skyGradient, hasLength(3));
    expect(AppPalette.night.isDark, isTrue);
    expect(AppPalette.dawn.isDark, isFalse);
    expect(AppSpacing.lg, 24);
    expect(AppRadius.pill, 999);
  });

  testWidgets(
    'MedicalDisclaimerGate shows and acknowledges the disclaimer when profile requires it',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          profileProvider.overrideWith(
            () => _FakeProfileController(
              const ProfileState(
                goals: <LibraryCategory>{},
                onboarded: true,
                medicalDisclaimerAcknowledged: false,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            home: MedicalDisclaimerGate(
              child: SizedBox.shrink(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text("This isn't medical advice"), findsOneWidget);

      await tester.tap(find.text('I understand'));
      await tester.pump();

      expect(container.read(profileProvider).medicalDisclaimerAcknowledged, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets('CreditsScreen shows EmptyState when there are no attributions',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: const CreditsScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(EmptyState), findsOneWidget);
  });

  testWidgets('ProfileScreen help row pushes the in-app help page',
      (tester) async {
    final container = _profileContainer();
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          builder: (_, _) => const ProfileScreen(),
          routes: [
            GoRoute(
              path: 'help',
              builder: (_, _) => const HelpScreen(),
            ),
            GoRoute(
              path: 'about',
              builder: (_, _) => const AboutScreen(),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile-row-help')));
    await tester.pumpAndSettle();

    expect(find.byType(HelpScreen), findsOneWidget);
  });

  testWidgets('ProfileScreen about row pushes the in-app about page',
      (tester) async {
    final container = _profileContainer();
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          builder: (_, _) => const ProfileScreen(),
          routes: [
            GoRoute(
              path: 'help',
              builder: (_, _) => const HelpScreen(),
            ),
            GoRoute(
              path: 'about',
              builder: (_, _) => const AboutScreen(),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('profile-row-about')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('profile-row-about')));
    await tester.pumpAndSettle();

    expect(find.byType(AboutScreen), findsOneWidget);
  });

  testWidgets('SettingsScreen renders the three bottom action rows',
      (tester) async {
    final container = _settingsContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: const Scaffold(body: SettingsScreen()),
        ),
      ),
    );
    await tester.pump();

    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-action-sign-out')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('settings-action-sign-out')), findsOneWidget);
    expect(
      find.byKey(const Key('settings-action-export-data')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('settings-action-delete-account')),
      findsOneWidget,
    );
  });

  testWidgets('PlayerController bootstrap state is neutral',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(playerProvider);

    expect(state.sessionId, '');
    expect(state.title, '');
    expect(state.subtitle, '');
    expect(state.narrator, '');
    expect(state.duration, Duration.zero);
    expect(state.category, isNull);
    expect(state.loading, isTrue);
  });
}
