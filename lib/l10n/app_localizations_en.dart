// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Serenity';

  @override
  String get appTagline => 'quiet mind · clear sky';

  @override
  String get commonMinShort => 'min';

  @override
  String get downloadStart => 'Download';

  @override
  String get downloadRemove => 'Downloaded';

  @override
  String get downloadBadge => 'Offline';

  @override
  String get playerPlay => 'Play';

  @override
  String get playerPause => 'Pause';

  @override
  String get playerSkipBack15 => 'Skip back 15 seconds';

  @override
  String get playerSkipForward15 => 'Skip forward 15 seconds';

  @override
  String get breatheReadyToBegin => 'Ready to begin';

  @override
  String breatheSemanticsSecondsLeft(Object phase, int seconds) {
    return '$phase, $seconds seconds left';
  }

  @override
  String commonDurationMinutes(num n) {
    return '$n min';
  }

  @override
  String get tabHome => 'Home';

  @override
  String get tabLibrary => 'Library';

  @override
  String get tabBreathe => 'Breathe';

  @override
  String get tabProfile => 'Profile';

  @override
  String get onboardingTitle => 'Find your\nnight sky.';

  @override
  String get onboardingSubtitle =>
      'Guided meditation, breathing, and sleep — set against the quiet of a starlit sky.';

  @override
  String get onboardingBegin => 'Begin';

  @override
  String get onboardingHaveAccount => 'I have an account';

  @override
  String get onboardingGoalsTitle => 'What brings you here?';

  @override
  String get onboardingGoalsSubtitle =>
      'Pick any that fit. We\'ll tailor tonight\'s suggestion to match.';

  @override
  String get onboardingGoalsContinue => 'Continue';

  @override
  String get onboardingGoalsSkip => 'Skip for now';

  @override
  String get authSignInTitle => 'Welcome back.';

  @override
  String get authSignUpTitle => 'Create your\nnight sky.';

  @override
  String get authSignInSubtitle => 'Your stars are waiting.';

  @override
  String get authSignUpSubtitle => 'A quiet companion, always with you.';

  @override
  String get authEmailHint => 'Email';

  @override
  String get authPasswordHint => 'Password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authContinueAsGuest => 'Continue as guest';

  @override
  String get authAppleSignInError => 'Sign-in was cancelled or failed.';

  @override
  String get authHaveAccountPrompt => 'Already have an account?';

  @override
  String get authNewPrompt => 'New to Serenity?';

  @override
  String get authSignUp => 'Sign up';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get homeHeadline => 'Let the stars settle.';

  @override
  String get homeTonight => 'Tonight\'s meditation';

  @override
  String get homeQuickStart => 'Quick start';

  @override
  String get scenePickerTitle => 'Background scene';

  @override
  String get sceneLabelOff => 'Voice only';

  @override
  String get sceneLabelRain => 'Rain';

  @override
  String get sceneLabelForest => 'Forest';

  @override
  String get sceneLabelWaves => 'Waves';

  @override
  String get sceneLabelFire => 'Fireplace';

  @override
  String get sceneLabelNight => 'Crickets';

  @override
  String get libraryTitle => 'Library';

  @override
  String get libraryHeadline => 'All sessions.';

  @override
  String get librarySearch => 'Search sessions';

  @override
  String get libraryCategoryAll => 'All';

  @override
  String get libraryCategorySleep => 'Sleep';

  @override
  String get libraryCategoryFocus => 'Focus';

  @override
  String get libraryCategoryStress => 'Stress';

  @override
  String get libraryCategoryMorning => 'Morning';

  @override
  String get libraryCategorySoundscapes => 'Soundscapes';

  @override
  String get libraryFilterOfflineOnly => 'Offline';

  @override
  String get libraryDetailAbout => 'About this session';

  @override
  String libraryDetailLongDescription(Object narrator, Object duration) {
    return 'A gently paced guided practice led by $narrator. Settle somewhere comfortable, dim the lights if you can, and let the voice become the landscape for the next $duration.';
  }

  @override
  String get libraryDetailBegin => 'Begin session';

  @override
  String libraryDetailMoreIn(Object category) {
    return 'More in $category';
  }

  @override
  String get libraryEmptyTitle => 'Nothing here yet';

  @override
  String get libraryEmptySubtitle =>
      'Try another category — or check back soon.';

  @override
  String get breatheTitle => 'Breathe';

  @override
  String get breatheHeadline => 'Guided patterns.';

  @override
  String get breatheSubtitle => 'Pick a rhythm. Follow the circle. Unwind.';

  @override
  String get breatheInhale => 'Inhale';

  @override
  String get breatheExhale => 'Exhale';

  @override
  String get breatheHold => 'Hold';

  @override
  String get breatheReady => 'Ready';

  @override
  String breatheRound(Object n, Object total) {
    return 'Round $n of $total';
  }

  @override
  String get breatheComplete => 'Complete.';

  @override
  String get breatheCompleteSubtitle =>
      'Notice the quiet that lives just under the breath.';

  @override
  String get breatheAgain => 'Breathe again';

  @override
  String get progressTitle => 'Progress';

  @override
  String get progressHeadline => 'Your quiet hours.';

  @override
  String get progressCurrentStreak => 'Current streak';

  @override
  String progressNightsInARow(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'nights in a row',
      one: 'night in a row',
    );
    return '$_temp0';
  }

  @override
  String get progressTotal => 'Total';

  @override
  String get progressSessions => 'Sessions';

  @override
  String get progressLongest => 'Longest';

  @override
  String get progressLast35Days => 'Last 35 days';

  @override
  String get progressLast35DaysHint =>
      'Each cell is a day. Brighter means longer.';

  @override
  String get progressAchievements => 'Achievements';

  @override
  String get progressMoodHeading => 'How you\'ve been';

  @override
  String get progressMoodHint => 'Your check-ins after recent sessions.';

  @override
  String get progressMoodEmpty =>
      'No check-ins yet. Finish a session to leave one.';

  @override
  String get progressThisWeek => 'This week';

  @override
  String progressThisWeekSummary(num days, num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days of practice · $minutes min',
      one: '1 day of practice · $minutes min',
      zero: 'No sessions yet — a quiet week.',
    );
    return '$_temp0';
  }

  @override
  String progressWeekDeltaUp(num n) {
    return '+$n min from last week';
  }

  @override
  String progressWeekDeltaDown(num n) {
    return '$n min fewer than last week';
  }

  @override
  String get progressWeekDeltaSame => 'Same as last week';

  @override
  String progressMoodAverage(Object emoji) {
    return 'Average mood $emoji';
  }

  @override
  String get progressFreezeAvailable => '1 freeze this week';

  @override
  String get progressFreezeUsed => 'Freeze used this week';

  @override
  String get progressFreezeHint =>
      'One skipped day per week won\'t break your streak.';

  @override
  String get achievementProgress => 'Progress';

  @override
  String get achievementUnitSessions => 'sessions';

  @override
  String get achievementUnitDays => 'days';

  @override
  String get achievementUnitMinutes => 'minutes';

  @override
  String achievementRemaining(num n, Object unit) {
    return '$n $unit to go';
  }

  @override
  String achievementDescriptionSessions(num n) {
    return 'Complete $n guided sessions — any length, any category. Each one counts toward this badge.';
  }

  @override
  String achievementDescriptionStreak(num n) {
    return 'Meditate on $n consecutive days. A freeze covers one missed day per week.';
  }

  @override
  String achievementDescriptionMinutes(num n) {
    return 'Accumulate $n total minutes of practice. Time spent listening — at any speed — counts.';
  }

  @override
  String get moodSheetTitle => 'How do you feel?';

  @override
  String get moodSheetSubtitle => 'A quick check-in helps track what works.';

  @override
  String get moodSheetSkip => 'Skip';

  @override
  String get moodLabel1 => 'Heavy';

  @override
  String get moodLabel2 => 'Tired';

  @override
  String get moodLabel3 => 'Steady';

  @override
  String get moodLabel4 => 'Calm';

  @override
  String get moodLabel5 => 'Radiant';

  @override
  String get profileProgress => 'Progress';

  @override
  String get profileProgressSubtitle => 'Streak, minutes, achievements';

  @override
  String get profilePremium => 'Serenity Premium';

  @override
  String get profilePremiumSubtitle => 'Unlock the full library';

  @override
  String get profilePremiumBadge => 'Free trial';

  @override
  String get profilePremiumActive => 'Active';

  @override
  String get profilePremiumTrial => 'Free trial';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileSettingsSubtitle => 'Notifications, sound, account';

  @override
  String get profileHelp => 'Help & support';

  @override
  String get profileHelpLaunchFailed => 'Couldn\'t open the mail app.';

  @override
  String get profileAbout => 'About';

  @override
  String get profileAboutTagline =>
      'A quiet companion, not a cure. If this practice feels like it\'s helping, let us know.';

  @override
  String get profileAboutLegalese => '© 2026 Serenity';

  @override
  String get helpFaqTitle => 'FAQ';

  @override
  String get helpContactTitle => 'Contact us';

  @override
  String get helpContactEmail => 'support@serenity.app';

  @override
  String get helpDiagnosticsTitle => 'Diagnostics';

  @override
  String get helpDiagnosticsHint =>
      'Include this info when reporting a problem';

  @override
  String helpDiagnosticsVersion(Object version) {
    return 'Version $version';
  }

  @override
  String helpDiagnosticsLocale(Object locale) {
    return 'Locale $locale';
  }

  @override
  String get helpFaqQ1 => 'Why isn\'t my streak counting up?';

  @override
  String get helpFaqA1 =>
      'A streak advances when you complete a session on a new day. Extra sessions on the same day do not add another day, and one missed day can be covered by the weekly freeze token for that ISO week.';

  @override
  String get helpFaqQ2 => 'How do I change reminder times?';

  @override
  String get helpFaqA2 =>
      'Open Settings, go to Notifications, and tap the time subtitle on an enabled reminder row to open the time picker.';

  @override
  String get helpFaqQ3 => 'Can I listen offline?';

  @override
  String get helpFaqA3 =>
      'Yes. Tap Download on any library session, then use the Offline filter in the Library to see what is saved on this device.';

  @override
  String get helpFaqQ4 => 'How do I switch language or theme?';

  @override
  String get helpFaqA4 =>
      'Open Settings and look in the Account section for Language and Theme.';

  @override
  String get helpFaqQ5 => 'What happens when I delete my account?';

  @override
  String get helpFaqA5 =>
      'Serenity clears the local progress, reminders, and other saved data on this device. Cloud accounts and sync are not live yet, so there is no remote account data to remove.';

  @override
  String get helpFaqQ6 => 'Is this medical advice?';

  @override
  String get helpFaqA6 =>
      'No. Serenity is a wellness app, not medical care. If you need that reminder again, open the Wellness disclaimer row in Settings.';

  @override
  String get aboutLinkOssLicenses => 'Open-source licenses';

  @override
  String get profileDisplayNameFallback => 'Luna';

  @override
  String get profileStatStreak => 'streak';

  @override
  String get profileStatDaysShort => 'd';

  @override
  String get profileStatMinutes => 'minutes';

  @override
  String get profileStatSessions => 'sessions';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsNotifications => 'NOTIFICATIONS';

  @override
  String get settingsPlayback => 'PLAYBACK';

  @override
  String get settingsAccount => 'ACCOUNT';

  @override
  String get settingsDailyReminder => 'Daily reminder';

  @override
  String get settingsDailyReminderSubtitle => '9:00 PM';

  @override
  String get settingsBedtimeReminder => 'Bedtime reminder';

  @override
  String get settingsBedtimeReminderSubtitle => '30 min before sleep';

  @override
  String get settingsHaptic => 'Haptic feedback';

  @override
  String get settingsBackgroundAudio => 'Background audio';

  @override
  String get settingsBackgroundAudioSubtitle => 'Continue when screen is off';

  @override
  String get settingsWifiDownload => 'Download over Wi-Fi only';

  @override
  String get settingsProfileRow => 'Profile';

  @override
  String get settingsAccountNameFallback => 'Luna';

  @override
  String get settingsAccountEmailFallback => 'luna@serenity.app';

  @override
  String settingsAccountSummary(Object name, Object email) {
    return '$name · $email';
  }

  @override
  String get settingsSubscription => 'Subscription';

  @override
  String get settingsSubscriptionPremiumActive => 'Premium · active';

  @override
  String get settingsSubscriptionFreeTrial => 'Free · 14 days left';

  @override
  String get settingsWellnessDisclaimer => 'Wellness disclaimer';

  @override
  String get settingsCredits => 'Credits';

  @override
  String get settingsCreditsTitle => 'Credits';

  @override
  String get settingsCreditsEmptyTitle => 'No bundled attributions yet';

  @override
  String get settingsCreditsEmptySubtitle =>
      'This page will list audio, music, and artwork credits as attribution-required assets land.';

  @override
  String get medicalDisclaimerTitle => 'This isn\'t medical advice';

  @override
  String get medicalDisclaimerBody =>
      'Meditation and breathing practices can support wellbeing, but they are not a substitute for professional care. Serenity is not intended to diagnose, treat, or manage medical or mental health conditions. If distress persists or feels overwhelming, talk to a qualified clinician.';

  @override
  String get medicalDisclaimerAcknowledge => 'I understand';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsTerms => 'Terms';

  @override
  String get legalPrivacyTitle => 'Privacy';

  @override
  String get legalTermsTitle => 'Terms';

  @override
  String legalLastUpdated(Object date) {
    return 'Last updated $date';
  }

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsSignOutDialogTitle => 'Sign out of Serenity?';

  @override
  String get settingsSignOutDialogBody =>
      'Your progress and preferences stay on this device. Sign back in anytime to pick up where you left off.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageChinese => '中文';

  @override
  String get settingsLanguageSheetTitle => 'Choose language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System default';

  @override
  String get settingsThemeDark => 'Night sky';

  @override
  String get settingsThemeLight => 'Dawn';

  @override
  String get settingsThemeAuto => 'Auto (time of day)';

  @override
  String get settingsThemeSheetTitle => 'Choose theme';

  @override
  String get settingsExportData => 'Export my data';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsDeleteAccountDialogTitle =>
      'Delete your Serenity account?';

  @override
  String get settingsDeleteAccountDialogBody =>
      'Your progress, streak and preferences on this device will be erased. This action cannot be undone.';

  @override
  String get settingsDeleteAccountExportFirst => 'Export then delete';

  @override
  String get settingsDeleteAccountExportFirstConfirmation =>
      'Data exported, account deleted';

  @override
  String get settingsDeleteAccountConfirm => 'Delete';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get premiumHeroTitle => 'Go deeper,\nsleep better.';

  @override
  String get premiumHeroSubtitle =>
      'Unlock the full Serenity library. 14 days free.';

  @override
  String get premiumBenefit1 => 'Unlimited meditations';

  @override
  String get premiumBenefit2 => 'All sleep stories';

  @override
  String get premiumBenefit3 => 'Premium soundscapes';

  @override
  String get premiumBenefit4 => 'New sessions weekly';

  @override
  String get premiumBenefit5 => 'Offline downloads';

  @override
  String get premiumPlanMonthly => 'Monthly';

  @override
  String get premiumPlanMonthlyPeriod => 'per month';

  @override
  String get premiumPlanYearly => 'Yearly';

  @override
  String get premiumPlanYearlyPeriod => 'per year · \$4.99/mo';

  @override
  String get premiumPlanYearlyBadge => 'Save 50%';

  @override
  String get premiumCta => 'Start 14-day free trial';

  @override
  String get premiumDisclaimer => 'Free for 14 days. Cancel anytime.';
}
