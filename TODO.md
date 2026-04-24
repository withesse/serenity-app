# TODO — blocked or deferred work

Things that can't be finished from inside the Flutter repo today. Each
item is waiting on a specific external resource, a Xcode / Android
Studio UI action, or a product-scope decision. The code seams are
already in place — most items are a 30-minute plug, not a rewrite.

Snapshot at commit `46b2f00`. Update when items clear or scope shifts.

---

## ⛔ Needs external credential / account

| Item | Blocker | Where it plugs in |
|---|---|---|
| Replace hardcoded version `'0.1.0'` in About dialog with `package_info_plus` | `pub.flutter-io.cn` was TLS-flaking when we tried `flutter pub add`. Retry on a stable network. | `lib/features/profile/profile_screen.dart` — replace `_appVersion` const with a runtime `PackageInfo.fromPlatform()` read |
| Sentry crash reporting goes live | Need a Sentry DSN + `flutter pub add sentry_flutter` | `lib/data/sentry_crash_reporter.dart` header has the 4-step activation recipe. Swap `crashReporterProvider` via `ProviderScope.overrides` in `main.dart`; pass DSN via `--dart-define=SENTRY_DSN=…` |
| Real analytics (Firebase / PostHog / Mixpanel) | Pick a vendor, get project id + config file, `flutter pub add` the SDK | `lib/data/analytics.dart` — subclass `Analytics` (interface already fires all event names from `AnalyticsEvents`), override `analyticsProvider` |
| Generate real mp3 audio for the 5 written scripts | Need Google Cloud service account JSON (free tier: 1M chars/mo) or Azure / Volcengine credentials | Scripts live in `docs/content-scripts/*.md`. Write a one-shot CLI under `tools/tts_render.dart` that reads frontmatter + `[pause:Ns]` cues, emits SSML, hits the TTS API, writes `assets/audio/<session-id>.<en\|zh>.mp3`. Update `player_controller.loadSession` to pick the locale variant |
| Real soundscapes for `rain-under-eaves` and `forest-at-dusk` | Download CC0 loops from Freesound (no auth needed, but manual curation) | `docs/content-scripts/rain-under-eaves.md` and `forest-at-dusk.md` already state what to look for. Place files at `assets/audio/scenes/<id>.mp3`. Log each in `assets/licenses/soundscapes.md` |
| Session cover art (currently gradient placeholders) | Midjourney subscription OR local Stable Diffusion setup | Store at `assets/covers/<session-id>.jpg`. Add `coverAsset` to `LibrarySession` (same pattern as `gradient`). Library tile + detail hero read it with a gradient fallback |

## 🛠 Needs Xcode UI (can't be scripted)

| Item | What to click | What to do after |
|---|---|---|
| iOS Widget Extension | File ▸ New ▸ Target ▸ Widget Extension. Product name `SerenityWidget`, bundle id `com.serenity.serenity_app.SerenityWidget`. Include Configuration Intent = NO | Replace generated stub with `ios/SerenityWidget/SerenityWidget.swift` already in repo. Add App Group `group.com.serenity.serenity_app` to **both** Runner and the new target. `WidgetBridge.pushTonight` Dart side is live — once the target builds, the widget reads those keys |
| Apple Watch app | File ▸ New ▸ Target ▸ Watch App. SwiftUI life cycle | Replace stub with `ios/SerenityWatch Watch App/ContentView.swift`. Register the WCSession delegate on the iOS side (small Swift shim next to `AppDelegate`). The Dart-side bridge can stay the same shape as `WidgetBridge` |
| Siri Shortcuts wire-up | Add Siri capability to Runner. Add `ios/Runner/SiriShortcuts.swift` to the Runner target in Xcode. Register the bridge in AppDelegate | Add one line in `AppDelegate.application(_:didFinishLaunchingWithOptions:)`: `SiriBridge.register(with: controller.binaryMessenger)`. `SiriBridge.donate` Dart side is already called from `player_controller.loadSession` |
| Real App Store signing | Apple Developer account, provisioning profiles | Replace debug-key fallback in `ios/Runner.xcodeproj` build settings. Same for Android: real keystore in `android/app/upload-keystore.jks` + `key.properties` |

## 🌐 Needs marketing / legal resource

| Item | Blocker |
|---|---|
| Universal Links (https deep links) | Requires a live marketing domain with `apple-app-site-association` JSON hosted at `/.well-known/`. Custom scheme `serenity://` already works; Universal Links is the iOS-preferred upgrade |
| Privacy Policy URL | Prose is in `lib/features/legal/legal_screen.dart` (bilingual). Needs a public URL in App Store Connect — host the same text on the marketing site |
| Terms of Service URL | Same as above |
| Replace placeholder support email `support@serenity.app` | Decide the real mailbox. Used in `lib/features/profile/profile_screen.dart` (`_supportEmail` const) and anywhere else support contact appears |
| Replace placeholder URL `https://serenity.app` | Currently used in share text (`lib/core/share.dart`). Swap to the real App Store + Play Store links |
| App Store Connect listing | 1024px icon ✅ already generated. Still need: 3 screenshot sizes × 5–8 scenes each, description EN + ZH, keywords EN + ZH, support URL, marketing URL, privacy URL |
| Play Store listing | Feature graphic, phone screenshots, description EN + ZH, content rating questionnaire |

## 🏛 Needs China-market compliance (if launching CN)

| Item | Blocker |
|---|---|
| ICP 备案 (工信部) | Hosting a server / domain in China |
| 应用商店备案 | Each CN app store (Huawei / Xiaomi / OPPO / vivo) has its own review quirks |
| 内容审核 | Sleep stories + meditation scripts need to pass 文化部 review — no religion-adjacent phrasing, no health claims |
| Real-name / implicit registration | Push to local authentication / OAuth provider (e.g., WeChat Open Platform) |

## ☁️ Backend (currently zero server-side)

| Item | Blocker | Notes |
|---|---|---|
| User accounts | Pick backend — Firebase Auth / Supabase / custom | Apple Sign In flow is already scaffolded in `lib/data/auth_store.dart`, but tokens are never validated server-side |
| Progress cloud sync | Same as above + a sync strategy | Hive boxes are per-device. `data_export.dart` can already produce a JSON dump — use that shape for upload |
| Subscription validation | StoreKit 2 server-to-server receipts + Play Billing server-side validation + an entitlement endpoint | `lib/data/iap_store.dart` trusts the client. A user who jailbreaks can currently mark themselves premium |
| Content CMS | Pick CMS (Contentful / Strapi / custom) | `LibraryRepository` is the seam. Current `StaticLibraryRepository` returns synchronously; swap for a `FutureProvider<List<LibrarySession>>` wrapping a CMS client |
| Remote config / feature flags | Firebase Remote Config or PostHog flags | Covers A/B tests and rolling out new session categories without a binary release |

## 🧪 Testing / release

| Item | Blocker |
|---|---|
| Real-device testing | Only simulator/emulator tested so far. Physical iPhone (for audio session real behaviour) + Android phone (for wake locks, notification channels) |
| TestFlight external beta | Apple Dev account + 10–20 testers; budget 2–4 weeks |
| Play Store internal testing track | Google Play Console setup |
| Accessibility sweep | VoiceOver labels pass (most widgets have semantic text but custom `CustomPaint` elements like `TimerRing` and `BreathingCircle` don't); contrast check on dawn palette at small sizes |
| Content legal review | Lawyer-pass on Privacy + ToS (current text is a good draft, not a signed-off version) |
| "Not medical advice" disclaimer | Product decision: where to surface it (onboarding, Settings, first session of each category?) |
| GDPR / CCPA data deletion | `data_export.dart` ships JSON on request. Deletion is wired via `ProgressController.reset()` + `SettingsController` clear. Needs a single "export then delete" flow in Settings that kicks both |

## 🔧 Small deferred code tasks

- [ ] Wire the **Credits / Attribution** page in Settings (slot is reserved — first attribution-required asset unblocks it)
- [ ] Restore integration test end-to-end under both `en` and `zh` locales (existing walk is locale-agnostic per LOW #9 fix, but hasn't been run under a forced zh locale)
- [ ] Verify `.gitignore` coverage for `android/build/` — it keeps showing up in `git status` (per previous observation)
- [ ] When `package_info_plus` lands, align on a single place to read app version (currently `TODO.md`, `profile_screen.dart` `_appVersion`, `README.md`, Settings footer literal)
- [ ] Optional: swap `DebugAnalytics.debugPrint` for a local file sink in debug builds so events can be inspected after the fact
