# Serenity — Road to App Store

_Generated 2026-04-20. Honest assessment of distance from current code to a submittable build._

---

## Current Completion

| Dimension | % | Notes |
|---|---|---|
| UI / UX frontend | 85% | All 15 screens done, polish remaining |
| Design system | 95% | MASTER.md + dual-theme palette (night + dawn) |
| Architecture | 80% | Router/state/theme solid, backend abstraction layer missing |
| Business logic | 30% | Flows work, real data missing |
| Content | 0% | All sessions are placeholders, audio is 10-min silence |
| Backend | 0% | No accounts, no subscription, no sync |
| Compliance / Store assets | 0% | No icon, no privacy policy, no Info.plist extras |

## Realistic Timeline

- **MVP path (free, single device, bundled content)**: **6-8 weeks full-time**
- **Full version (paid, synced, proper content)**: **2-4 months full-time**
- **With original recorded content**: **6-12 months**

---

## 🚫 Hard Blockers for App Store Review

These WILL cause rejection:

| Item | Effort |
|---|---|
| **Apple Sign In** | Required if any other sign-in is offered |
| **StoreKit 2 integration** | Real subscription purchase + receipt validation + entitlement server |
| **Privacy Manifest** (iOS 17+) | Declare data collection, SDK usage |
| **Info.plist usage descriptions** | NSMicrophone, NSAppTransportSecurity if http, etc. |
| **`UIBackgroundModes: audio`** | Required for meditation playback to continue when screen is off |
| **Launch screen** | Currently Flutter default — must customise |
| **App icon** | Currently Flutter default — must replace all sizes |
| **Privacy Policy URL** | Mandatory in App Store Connect |
| **Terms of Service URL** | Mandatory |
| **App Store metadata** | 1024px icon, 3 screenshot sizes, description, keywords, support URL |
| **Export compliance** | Encryption declaration on every upload |
| **Age rating questionnaire** | All answered in App Store Connect |

## 🎧 Product Content (no content = no one uses it)

| Item | Effort |
|---|---|
| Real meditation audio | Biggest gap. Options: license existing pack (~$500-2000), or commission/record (months) |
| Narrator voices | Multiple voices, studio recording, or licensed |
| Sleep story scripts | 20-30 min each, usually written + recorded professionally |
| Soundscapes | Royalty-free loops or licensed |
| Session cover art | Every card currently uses gradient placeholder |
| Content CMS | Sessions shouldn't require app updates |

## ☁️ Backend (currently all local)

| Item |
|---|
| User accounts (Apple Sign In + email/social) |
| Progress cloud sync (Hive is per-device) |
| Subscription entitlement server (validate receipts, answer "is user Premium?") |
| Content CDN + signed URLs |
| Analytics (Firebase / Mixpanel / PostHog) |
| Crash reporting (Sentry / Crashlytics) |
| Remote config (feature flags, copy updates) |

## 🎛 Feature Gaps

| Item | Notes |
|---|---|
| Daily reminders actually scheduling | Settings toggle exists — `flutter_local_notifications` not wired |
| iOS audio session config | Handle interruptions (calls, other apps), route changes |
| Offline downloads | Premium benefit — needs file manager |
| HealthKit Mindful Minutes integration (iOS) | Nice-to-have on Apple platforms |
| Error / empty / loading states | Most screens assume happy path |
| Accessibility | VoiceOver labels, Dynamic Type, contrast checks on dawn palette |
| `AppLifecycleObserver` | Pause aurora/star animations when backgrounded (battery) |
| Bundled fonts | `google_fonts` loads at runtime; should ship .ttf in assets |

## 🧪 Testing & Compliance

| Item |
|---|
| Real-device testing (we've only used simulators) |
| TestFlight external beta (10-20 people, 2-4 weeks) |
| Privacy policy + terms of service (lawyer-reviewed) |
| "Not medical advice" content disclaimer |
| GDPR (EU), CCPA (California) compliance |
| 中国大陆：ICP 备案 + 内容审核 |
| Content rating for sensitive topics (grief, anxiety, trauma) |

---

## 📋 Minimal Ship Path (MVP)

If goal is fastest submission:

1. **Cut subscription + auth** → free version (saves Apple Sign In + StoreKit + account backend = 1-2 months)
2. **License an audio pack** instead of recording (~$500-2000 one-time)
3. **Hardcode content in bundle** — accept that V1 requires a new release for each content update
4. **Firebase end-to-end** — Auth + Firestore + Crashlytics + Analytics in one SDK
5. **Real-device testing + TestFlight 2 weeks + submit**

≈ **6-8 weeks full-time** to submission.
