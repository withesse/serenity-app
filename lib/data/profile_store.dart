import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../features/library/library_data.dart';
import 'analytics.dart';
import 'crash_reporter.dart';

/// The user's answers from the onboarding questionnaire. Goals steer which
/// session appears on Home at each time of day; [onboarded] gates the
/// splash → home vs splash → questionnaire routing.
@immutable
class ProfileState {
  const ProfileState({
    required this.goals,
    required this.onboarded,
    required this.medicalDisclaimerAcknowledged,
  });

  final Set<LibraryCategory> goals;
  final bool onboarded;
  final bool medicalDisclaimerAcknowledged;

  ProfileState copyWith({
    Set<LibraryCategory>? goals,
    bool? onboarded,
    bool? medicalDisclaimerAcknowledged,
  }) =>
      ProfileState(
        goals: goals ?? this.goals,
        onboarded: onboarded ?? this.onboarded,
        medicalDisclaimerAcknowledged: medicalDisclaimerAcknowledged ??
            this.medicalDisclaimerAcknowledged,
      );
}

class ProfileController extends Notifier<ProfileState> {
  static const _boxName = 'settings';
  static const _prefix = 'profile.';
  static const _goalsKey = '${_prefix}goals';
  static const _onboardedKey = '${_prefix}onboarded';
  static const _medicalDisclaimerAcknowledgedKey =
      '${_prefix}medicalDisclaimerAcknowledged';

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  @override
  ProfileState build() {
    _migrateLegacyKeys();
    final raw = (_box.get(_goalsKey) as List?)?.cast<String>() ?? const [];
    final goals = <LibraryCategory>{};
    for (final name in raw) {
      final match = LibraryCategory.values
          .where((c) => c.name == name && c != LibraryCategory.all);
      if (match.isNotEmpty) goals.add(match.first);
    }
    return ProfileState(
      goals: goals,
      onboarded: _box.get(_onboardedKey, defaultValue: false) as bool,
      medicalDisclaimerAcknowledged: _box.get(
        _medicalDisclaimerAcknowledgedKey,
        defaultValue: false,
      ) as bool,
    );
  }

  Future<void> setGoals(Set<LibraryCategory> goals) async {
    final filtered = goals.where((g) => g != LibraryCategory.all).toSet();
    await _box.put(_goalsKey, filtered.map((g) => g.name).toList());
    state = state.copyWith(goals: filtered);
  }

  Future<void> markOnboarded() async {
    await _box.put(_onboardedKey, true);
    state = state.copyWith(onboarded: true);
    await ref.read(analyticsProvider).track(
      AnalyticsEvents.onboardingComplete,
      {'goals': state.goals.map((g) => g.name).toList()},
    );
  }

  Future<void> acknowledgeMedicalDisclaimer() async {
    await _box.put(_medicalDisclaimerAcknowledgedKey, true);
    state = state.copyWith(medicalDisclaimerAcknowledged: true);
    await ref.read(analyticsProvider).track(
      AnalyticsEvents.disclaimerAcknowledged,
    );
    await ref.read(crashReporterProvider).breadcrumb(
      AnalyticsEvents.disclaimerAcknowledged,
    );
  }

  Future<void> wipeAccountData() async {
    // Also clear the pre-migration keys in case a prior migration copied
    // but didn't finish deleting (crash between write and delete). A plain
    // wipe-by-namespaced-name would leave an orphan the next build() reads.
    await _box.deleteAll([
      _goalsKey,
      _onboardedKey,
      _medicalDisclaimerAcknowledgedKey,
      ..._legacyRename.keys,
    ]);
    state = build();
  }

  static const _legacyRename = <String, String>{
    'profileGoals': _goalsKey,
    'onboarded': _onboardedKey,
    'medicalDisclaimerAcknowledged': _medicalDisclaimerAcknowledgedKey,
  };

  /// One-shot rename from the pre-namespace keys that shipped before the
  /// shared-box hardening. Runs synchronously on build() so the UI never
  /// observes a blank frame. Legacy keys are deleted unconditionally once
  /// observed — a half-migrated state would otherwise survive forever.
  void _migrateLegacyKeys() {
    for (final entry in _legacyRename.entries) {
      if (!_box.containsKey(entry.key)) continue;
      if (!_box.containsKey(entry.value)) {
        _box.put(entry.value, _box.get(entry.key));
      }
      _box.delete(entry.key);
    }
  }
}

final profileProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);
