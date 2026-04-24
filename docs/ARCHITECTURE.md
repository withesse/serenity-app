# Serenity — Architecture

_Snapshot: 2026-04-23. Frozen against commit_ `22b5562613b177715290f95a4fc8cb083fbc34de`. Purpose: capture the
stable decisions behind the current code so a returning reader can answer
"where does X live?" and "why was it done this way?" without re-reading the
whole tree.

For a walk of the files, see `README.md`. For gap analysis vs App Store
readiness, see `ROADMAP.md`.

---

## 1. Product scope

A cross-platform (iOS + Android) meditation app with four tabs: Home /
Library / Breathe / Profile. Audio-first — the timer ring, background
playback, and lock-screen controls are the core surfaces. Two themes
(night sky + dawn) are a brand differentiator, not a preference checkbox.

The codebase currently ships with bundled content (one placeholder mp3,
hardcoded session metadata). Remote content, real subscription validation,
and a user-identity backend are explicit extension points rather than
missing features — see §11.

---

## 2. Tech stack

| Concern | Choice | Why |
|---|---|---|
| Framework | Flutter 3.41, Dart 3.11 | One codebase for iOS + Android; native look is an anti-goal here |
| State | `flutter_riverpod` 2.x (`Notifier`/`NotifierProvider`) | Typed, compile-time graph, no BuildContext leak |
| Routing | `go_router` 14.x with `ShellRoute` | Declarative + deep-link friendly |
| Persistence | `hive_flutter` (dynamic boxes) | Fast, embedded, no generated adapters needed |
| Audio | `just_audio` + `just_audio_background` + `audio_session` | Lock-screen controls, interruption handling |
| Notifications | `flutter_local_notifications` + `timezone` | Scheduled reminders that respect OS settings |
| Auth | `sign_in_with_apple` | App Store requirement when offering any other sign-in |
| IAP | `in_app_purchase` | StoreKit 2 + Play Billing through one abstraction |
| HealthKit | `health` (iOS only at runtime) | Mindful Minutes write-back |
| Share | `share_plus` | Native share sheet, iPad popover anchor |
| i18n | `flutter_gen_l10n` (`.arb` → `AppLocalizations`) | Stock toolchain |

Dependencies are justified at point of introduction — `pubspec.yaml` sticks
to "added because [feature] needed it", no general utility kitchen sinks.

---

## 3. Layer shape

```
main.dart                          Hook errors, init native, runApp
└── app.dart                       MaterialApp.router
    ├── core/           "How" the app renders + navigates
    │   ├── theme/     Palette, typography, spacing, motion
    │   ├── widgets/   Reusable presentation (glass card, pill button, star field)
    │   ├── router/    GoRouter wiring — single source of paths
    │   └── share.dart Small cross-cutting utility surface
    │
    ├── data/          "What" the app knows + persists (no widgets live here)
    │   ├── *_store.dart        Hive-backed Notifier controllers
    │   ├── *_bridge.dart       MethodChannel shims to native (Siri / Widget)
    │   ├── library_repository.dart   Abstracts the session catalogue
    │   ├── analytics.dart     Event taxonomy + pluggable sink
    │   ├── crash_reporter.dart Error sink, FlutterError.onError hook
    │   ├── data_export.dart   GDPR-style JSON dump
    │   └── insights.dart      Derived weekly rollup
    │
    ├── features/      "Where" — one folder per screen/feature
    │   └── <feature>/<feature>_screen.dart + widgets/ + <feature>_data.dart
    │
    └── l10n/          Generated — don't hand-edit the .dart files
```

**Rule of thumb**: if a widget imports from `data/*_store.dart`, it should
be a `ConsumerWidget` or `ConsumerStatefulWidget`. If a file under `data/`
imports from `features/`, it's probably a mistake (exception:
`insights.dart` imports `progress_data.dart` for the `DayEntry` type —
acceptable because the type is plain data).

Recent profile additions follow the same rule: `help_screen.dart`,
`about_screen.dart`, `credits_screen.dart`, and
`medical_disclaimer_dialog.dart` stay in `features/profile/`; the shared
constants/helper surface (`appVersion`, `supportEmail`, the common top bar)
live in `_profile_support.dart` beside them.

---

## 4. State management contract

Every Riverpod notifier in this project follows the same shape:

```dart
class FooController extends Notifier<FooState> {
  static const _boxName = 'settings' | 'progress';
  static const _key = 'foo';

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  @override
  FooState build() => _read();

  // Public mutators are all Future<void> — Hive writes are async.
  Future<void> setBar(Bar b) async { ... await _box.put(_key, ...); state = _read(); }
}

final fooProvider = NotifierProvider<FooController, FooState>(FooController.new);
```

Conventions:

- **No `async build()`** — initial state is synchronous; if a box read
  blocks, the UI was already going to wait on that box anyway.
- **`state = _read()` after every write** — single source of truth is the
  box, not in-memory state. Cheap for our box sizes.
- **Analytics inside the mutator**, not the call site — event-per-mutation
  is automatic, call sites can't forget.
- **No controller calls another controller's `state`** — side effects
  flow through `ref.read(otherProvider.notifier).method()`.
- **Account wipes are explicit methods, not ad-hoc box clears** —
  `ProfileController.wipeAccountData`, `FavouritesController.wipeAll`,
  `DownloadsController.wipeAll`, and `SettingsController.wipeUserPreferences`
  define what "delete account" resets.

---

## 5. Persistence

Two Hive boxes, both `dynamic` (no adapters), opened in `main.dart`:

| Box | Owners | Keys |
|---|---|---|
| `settings` | `SettingsController`, `FavouritesController`, `ProfileController`, `AuthController`, `IapController`, `DownloadsController` | `dailyReminder`, `language`, `themeMode`, `favourites`, `profileGoals`, `onboarded`, `downloads`, etc. |
| `progress` | `ProgressController`, `MoodController` | `daysMinutes`, `currentStreak`, `longestStreak`, `totalMinutes`, `sessionsCompleted`, `lastSessionDate`, `freezeUsedWeek`, `moods` |

Boxes are `dynamic` so we can stash any JSON-safe type without generating
adapters. Each controller owns its key namespace — no cross-writes. New
boxes require an `openBox` call in `main.dart` _before_ `runApp`.

`data_export.dart` iterates both boxes to produce the GDPR dump. Adding a
third box means updating the `_boxes` constant there.

Delete-account flow deliberately wipes through controller APIs before
routing away, so onboarding flags, disclaimer acknowledgement, downloads,
favourites, and user-tunable settings all fall back to defaults together.

---

## 6. Routing

```
/                       SplashScreen                 → /onboarding or /home
/onboarding             OnboardingScreen             → /onboarding/goals or /auth
/onboarding/goals       QuestionnaireScreen          → /home
/auth                   AuthScreen

ShellRoute (AppShell — bottom nav):
  /home                 HomeScreen
  /library              LibraryScreen
    /library/session/:id  LibraryDetailScreen
  /breathe              BreatheScreen
  /profile              ProfileScreen
    /profile/help         HelpScreen
    /profile/about        AboutScreen
    /profile/settings     SettingsScreen
      /profile/settings/credits  CreditsScreen
    /profile/progress     ProgressScreen
      /profile/progress/achievement/:id  AchievementDetailScreen
    /profile/premium      PremiumScreen

Fullscreen (no bottom nav):
  /breathe/session      BreatheSessionScreen (techniqueId via extra)
  /player/:id           PlayerScreen
  /legal/privacy        PrivacyPolicyScreen
  /legal/terms          TermsOfServiceScreen
```

Transitions:
- Tab-to-tab uses `NoTransitionPage` — the crossfade between two glass
  surfaces ghosted visibly, so we slide-up only.
- Detail pushes use `_fadePage` (slide-up, no fade) for the same reason.

Deep links: the custom scheme `serenity://` is declared in both
`ios/Runner/Info.plist` and `android/app/src/main/AndroidManifest.xml`.
`go_router` picks up the initial URI with no extra wiring; any of the
paths above can be deep-linked.

`AppShell` now wraps its child in `MedicalDisclaimerGate`. That keeps the
required first-run disclaimer outside the splash-routing decision and makes
the gate resilient if the app is killed after onboarding is marked complete
but before the acknowledgement write lands.

---

## 7. Theming

Two palettes ship as a `ThemeExtension<AppPalette>`:
- `AppPalette.night` — deep violet / aurora backdrop, dense star field
- `AppPalette.dawn` — cream / pale lavender, no star layer

Access from widgets via the `context.palette` extension
(`lib/core/theme/app_palette.dart`). Never hardcode a color for which a
palette token exists.

Theme mode has four values in `AppThemeMode`:
- `system` — follows OS
- `dark` / `light` — locked
- `auto` — switches on hour boundaries (06:00 dawn / 18:00 night).
  Implemented by `autoThemeClockProvider`, a `NotifierProvider` that
  schedules a single `Timer` to the _next_ boundary and self-invalidates
  on fire. `AppLifecycleListener.onResume` in `SerenityApp` forces a
  resync so a suspended app doesn't miss a boundary.

Per-session gradients (`LibrarySession.gradient`) are lerped toward white
in dawn mode (`_softenForPalette` helper) so they read as pastel tiles
instead of dark slabs on the cream sky.

---

## 8. Internationalisation

- `lib/l10n/app_en.arb` is the template; `app_zh.arb` mirrors every key.
- `flutter gen-l10n` produces `app_localizations*.dart` — never hand-edit.
- Read via `L10n.of(context).someKey` (alias generated from `output-class`
  in `l10n.yaml`).
- Session text (`title`, `narrator`, `tagline`) is **not** in ARB — it
  lives in `_zhSessions` inside `library_data.dart` and is resolved via
  `LibrarySession.localized(Locale)`. Rationale: ARB keys per session ID
  would balloon the ARB; a per-locale record scales better and keeps
  editorial copy close to its session.
- Minute labels use the ARB key `commonDurationMinutes(n)` so "10 min"
  renders as "10 分钟" in zh.

---

## 9. Cross-cutting abstractions

These exist specifically so the SDK / service they front can be swapped
at release time without touching feature code.

| Abstraction | File | Swap target |
|---|---|---|
| Analytics | `data/analytics.dart` | Firebase / PostHog / Mixpanel — rebind `analyticsProvider` |
| Crash reporter | `data/crash_reporter.dart` | Sentry — see `data/sentry_crash_reporter.dart` for the ready-to-wire shim |
| Session catalogue | `data/library_repository.dart` | CMS / remote API — `StaticLibraryRepository` is the current binding |
| Siri donation | `data/siri_bridge.dart` | `MethodChannel` → `ios/Runner/SiriShortcuts.swift` (registered in `AppDelegate`) |
| Widget state | `data/widget_bridge.dart` | `MethodChannel` → native UserDefaults writer; iOS Widget Extension reads via App Group |
| Haptics gate | `data/haptics.dart` | Wraps `HapticFeedback` but checks the settings toggle first |
| Credits / attribution | `data/attribution.dart` | Manual bundled-asset register consumed by `features/profile/credits_screen.dart`; source links only, no separate `licenseUrl` field |

Each abstraction's doc comment lists the _exact_ steps to activate the
real backend (DSN env, config file path, provider override). That's
intentional: the activation path is deployment-critical and must not
require reading the SDK's upstream README.

---

## 10. Native integrations

iOS-side Swift scaffolds live beside the Flutter code but need Xcode
target wiring (can't be scripted from Flutter):

| File | Target needed |
|---|---|
| `ios/SerenityWidget/SerenityWidget.swift` | Widget Extension (File ▸ New ▸ Target) |
| `ios/SerenityWatch Watch App/ContentView.swift` | Watch App target |
| `ios/Runner/SiriShortcuts.swift` | Add to Runner target + enable Siri capability |

App Group `group.com.serenity.serenity_app` is the shared container between
Runner + Widget + Watch. The Dart `widget_bridge.dart` writes keys
(`tonight_session_id`, `streak`, ...) there; the Swift side reads them.

Android side: manifest is already configured for:
- Foreground audio service (`just_audio_background`)
- Scheduled alarms (reminders)
- Deep links (custom scheme)
- Desugaring + `minSdk 26` for `health` + `flutter_local_notifications`

`MainActivity` extends `AudioServiceFragmentActivity` (the Fragment
variant) so the `health` plugin's `ComponentActivity` cast succeeds — the
plain `AudioServiceActivity` failed that cast at runtime.

---

## 11. Extension points

Places deliberately left as seams for post-MVP work:

1. **Remote content** — `LibraryRepository` methods are synchronous today
   because data is bundled. Switching to async (`Future<List<LibrarySession>>`)
   requires making the three call sites `FutureBuilder`s or wrapping in
   a `FutureProvider`. No feature code imports `librarySessions` directly.
2. **Bundled locale audio / future remote audio** — `PlayerController`
   resolves assets through `_audioAssetFor(sessionId, locale)` and
   `_setAudioAssetWithFallback`, preferring `assets/audio/<id>.<lang>.mp3`
   and falling back to the placeholder asset. When a CDN is live, swap
   the source builder there instead of changing widget call sites.
3. **Offline downloads** — `DownloadsController` is a Timer-driven mock.
   The state machine matches what `flutter_downloader` exposes; replace
   the simulator in `start()` with real enqueue + progress stream.
4. **Analytics backend** — override `analyticsProvider` in a `ProviderScope`
   overrides list when `runApp`. Events never touch SDK symbols, so
   switching vendors is a one-file swap.
5. **Crash backend** — same pattern, plus the `SentryCrashReporter`
   header comment lists the four concrete steps to activate.
6. **Auth / identity** — `AuthController` currently handles Apple + guest
   session. Cloud sync would attach a `UserRepository` that syncs the
   `progress` + `settings` boxes on sign-in.

---

## 12. Testing

58 tests split across four files:

| File | Scope | Approach |
|---|---|---|
| `test/widget_test.dart` | Widget-level regressions (disclaimer gate, credits empty state, profile routing, settings actions, player bootstrap) | Real widgets with minimal provider overrides |
| `test/logic_test.dart` | Pure helpers (`tonightRecommendation`, `Achievement.percent`, `MoodEntry`, `StaticLibraryRepository`, `LibrarySession.localized`, `computeWeeklyInsights`, timer semantics, TTS/audio helpers) | No Flutter bindings needed except where helper APIs require them |
| `test/hive_stores_test.dart` | Hive-backed controllers (favourites, mood, profile, downloads, progress, settings wipes) | Temp-dir Hive per test, fresh `ProviderContainer` per case; downloads test waits 4s for the simulator |
| `integration_test/app_flow_test.dart` | End-to-end screen walk | `IntegrationTestWidgetsFlutterBinding`; drives real time via `runAsync` |

`dart analyze` must stay at 0 issues before every commit. Integration test
is adapted to the current onboarding flow (tolerates both first-launch
questionnaire path and returning-user bypass).

`weeklyInsightsProvider` exposes `computeWeeklyInsights` as
`@visibleForTesting`, so week-over-week math is covered directly instead of
only through the Progress UI.

---

## 13. Known invariants

Things future changes must preserve:

- **Hive open order in `main.dart` is load-bearing**: notifiers access
  their box lazily via `Hive.box<dynamic>(name)`; opening must happen
  before any notifier's `build()` fires.
- **`AppThemeMode.auto` and `AppLifecycleListener.onResume`**: remove the
  listener and the theme freezes on the hour of last foregrounding.
- **`FavouritesController` stores raw session ids**: both library session
  ids and breathing technique ids live in the same Set. Any UI that
  assumes one or the other must filter by prefix or known-id list.
- **`progress` box holds moods too**: `MoodController` uses `progress` box
  key `moods` (not a new box) to avoid an extra `openBox` in `main.dart`.

## 14. Lifecycle gates

- **Medical disclaimer**: `MedicalDisclaimerGate` lives above all tab
  routes in `AppShell`, so `onboarded == true &&
  medicalDisclaimerAcknowledged == false` always produces the modal even
  after a cold restart.
- **Delete-account reset**: settings-driven account deletion must call the
  controller wipe methods before routing to `/onboarding`; otherwise splash
  can race against stale local state.

## 15. Audit history

- Deep audit v1 closed 12 issues (3 HIGH, 5 MEDIUM, 4 LOW) across progress
  rolling, audio interruptions, downloads timing, auto-theme lifecycle,
  player/localisation defects, and integration-test brittleness.
- Deep audit v2 closed 10 issues (2 HIGH, 4 MEDIUM, 4 LOW) across account
  wipe semantics, disclaimer gating, player duration/session state, profile
  operational telemetry, attribution cleanup, and weak regression tests.
