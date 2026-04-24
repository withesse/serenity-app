import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_motion.dart';
import '../widgets/app_shell.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/breathe/breathe_screen.dart';
import '../../features/breathe/breathe_session_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/legal/legal_screen.dart';
import '../../features/library/library_detail_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/questionnaire_screen.dart';
import '../../features/player/player_screen.dart';
import '../../features/profile/achievement_detail_screen.dart';
import '../../features/profile/about_screen.dart';
import '../../features/profile/credits_screen.dart';
import '../../features/profile/help_screen.dart';
import '../../features/profile/premium_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/progress_screen.dart';
import '../../features/profile/settings_screen.dart';
import '../../features/splash/splash_screen.dart';

/// Deep-link URLs work without extra wiring — go_router parses the initial
/// URI from the platform. Supported entry points:
///   `serenity://library/session/:id`  → session detail
///   `serenity://player/:id`           → direct into the player
///   `serenity://breathe`              → breathing catalogue
/// Custom scheme is declared in ios/Runner/Info.plist and
/// android/app/src/main/AndroidManifest.xml.
final appRouterProvider = Provider<GoRouter>((ref) => _buildRouter());

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (_, state) =>
            _fadePage(state, const OnboardingScreen()),
        routes: [
          GoRoute(
            path: 'goals',
            pageBuilder: (_, state) => _fadePage(
              state,
              const OnboardingQuestionnaireScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/auth',
        pageBuilder: (_, state) => _fadePage(state, const AuthScreen()),
      ),

      // Bottom-nav shell. Tab-to-tab uses NoTransitionPage — fading two glass
      // surfaces into each other produced a visible ghost during the 400ms
      // crossfade. Pushed detail screens (settings/premium/progress) keep the
      // fade because they animate on top of an unchanged tab.
      ShellRoute(
        builder: (_, _, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (_, state) =>
                NoTransitionPage(key: state.pageKey, child: const HomeScreen()),
          ),
          GoRoute(
            path: '/library',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const LibraryScreen(),
            ),
            routes: [
              GoRoute(
                path: 'session/:id',
                pageBuilder: (_, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: LibraryDetailScreen(
                      sessionId: state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/breathe',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const BreatheScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
            ),
            routes: [
              GoRoute(
                path: 'help',
                pageBuilder: (_, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const HelpScreen(),
                ),
              ),
              GoRoute(
                path: 'about',
                pageBuilder: (_, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const AboutScreen(),
                ),
              ),
              GoRoute(
                path: 'settings',
                pageBuilder: (_, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const SettingsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'credits',
                    pageBuilder: (_, state) => NoTransitionPage(
                      key: state.pageKey,
                      child: const CreditsScreen(),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'progress',
                pageBuilder: (_, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const ProgressScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'achievement/:id',
                    pageBuilder: (_, state) => NoTransitionPage(
                      key: state.pageKey,
                      child: AchievementDetailScreen(
                        id: state.pathParameters['id']!,
                      ),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'premium',
                pageBuilder: (_, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const PremiumScreen(),
                ),
              ),
            ],
          ),
        ],
      ),

      // Fullscreen (no bottom nav)
      GoRoute(
        path: '/breathe/session',
        pageBuilder: (_, state) => _fadePage(
          state,
          BreatheSessionScreen(techniqueId: state.extra as String?),
        ),
      ),
      GoRoute(
        path: '/player/:id',
        pageBuilder: (_, state) => _fadePage(
          state,
          PlayerScreen(sessionId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/legal/privacy',
        pageBuilder: (_, state) =>
            _fadePage(state, const PrivacyPolicyScreen()),
      ),
      GoRoute(
        path: '/legal/terms',
        pageBuilder: (_, state) =>
            _fadePage(state, const TermsOfServiceScreen()),
      ),
    ],
  );
}

/// Slide-in page transition — the new route slides up from the bottom over the
/// old one. Unlike a crossfade, this does NOT render the outgoing route at
/// partial opacity, so glass surfaces layered on top of glass surfaces don't
/// produce the ghost-image artefact we saw with [FadeTransition].
CustomTransitionPage<T> _fadePage<T>(GoRouterState state, Widget child) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppMotion.pageTransition,
    reverseTransitionDuration: AppMotion.pageTransition,
    transitionsBuilder: (_, animation, _, child) {
      // Slide only — no fade. The child's AuroraBackground Scaffold is
      // opaque, so sliding it from below physically covers the outgoing
      // page. Any fade would re-introduce glass-on-glass ghosting.
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: AppMotion.pageCurve),
      );
      return SlideTransition(position: slide, child: child);
    },
  );
}
