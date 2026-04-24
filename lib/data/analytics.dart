import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Product telemetry interface. Kept abstract so we can swap in Firebase
/// Analytics / PostHog / Mixpanel at release time without touching the
/// call sites. The default binding is [DebugAnalytics] — prints events
/// in debug builds and no-ops in profile/release, so nothing leaves the
/// device until a real implementation is wired.
///
/// Event-naming convention: `feature_action`, snake_case. Properties stay
/// flat (no nested maps) so every backend can ingest them as-is.
abstract class Analytics {
  Future<void> track(String event, [Map<String, Object?> properties = const {}]);
  Future<void> identify(String userId, [Map<String, Object?> traits = const {}]);
}

class DebugAnalytics implements Analytics {
  const DebugAnalytics();

  @override
  Future<void> track(String event,
      [Map<String, Object?> properties = const {}]) async {
    if (!kDebugMode) return;
    debugPrint('[analytics] $event ${properties.isEmpty ? '' : properties}');
  }

  @override
  Future<void> identify(String userId,
      [Map<String, Object?> traits = const {}]) async {
    if (!kDebugMode) return;
    debugPrint('[analytics] identify=$userId ${traits.isEmpty ? '' : traits}');
  }
}

/// Canonical event names. Centralised so a typo in one call site can't
/// fragment the analytics schema, and a rename ripples cleanly.
class AnalyticsEvents {
  AnalyticsEvents._();
  static const onboardingComplete = 'onboarding_complete';
  static const sessionStarted = 'session_started';
  static const sessionCompleted = 'session_completed';
  static const breathingStarted = 'breathing_started';
  static const breathingCompleted = 'breathing_completed';
  static const moodRecorded = 'mood_recorded';
  static const sessionFavourited = 'session_favourited';
  static const sessionShared = 'session_shared';
  static const themeChanged = 'theme_changed';
  static const languageChanged = 'language_changed';
  static const premiumViewed = 'premium_viewed';
  static const disclaimerAcknowledged = 'disclaimer_acknowledged';
  static const accountDeleted = 'account_deleted';
  static const accountDeletedAfterExport = 'account_deleted_after_export';
  static const dataExported = 'data_exported';
  static const libraryOfflineFilterToggled = 'library_offline_filter_toggled';
  static const helpOpened = 'help_opened';
  static const helpContactTapped = 'help_contact_tapped';
  static const creditsOpened = 'credits_opened';
  static const aboutOpened = 'about_opened';
  static const disclaimerReopened = 'disclaimer_reopened';
}

final analyticsProvider = Provider<Analytics>((_) => const DebugAnalytics());
