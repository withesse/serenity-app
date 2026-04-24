import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Serenity'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'quiet mind · clear sky'**
  String get appTagline;

  /// No description provided for @commonMinShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get commonMinShort;

  /// No description provided for @downloadStart.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadStart;

  /// No description provided for @downloadRemove.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloadRemove;

  /// No description provided for @downloadBadge.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get downloadBadge;

  /// No description provided for @playerPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playerPlay;

  /// No description provided for @playerPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get playerPause;

  /// No description provided for @playerSkipBack15.
  ///
  /// In en, this message translates to:
  /// **'Skip back 15 seconds'**
  String get playerSkipBack15;

  /// No description provided for @playerSkipForward15.
  ///
  /// In en, this message translates to:
  /// **'Skip forward 15 seconds'**
  String get playerSkipForward15;

  /// No description provided for @breatheReadyToBegin.
  ///
  /// In en, this message translates to:
  /// **'Ready to begin'**
  String get breatheReadyToBegin;

  /// No description provided for @breatheSemanticsSecondsLeft.
  ///
  /// In en, this message translates to:
  /// **'{phase}, {seconds} seconds left'**
  String breatheSemanticsSecondsLeft(Object phase, int seconds);

  /// No description provided for @commonDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String commonDurationMinutes(num n);

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get tabLibrary;

  /// No description provided for @tabBreathe.
  ///
  /// In en, this message translates to:
  /// **'Breathe'**
  String get tabBreathe;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Find your\nnight sky.'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Guided meditation, breathing, and sleep — set against the quiet of a starlit sky.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingBegin.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get onboardingBegin;

  /// No description provided for @onboardingHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I have an account'**
  String get onboardingHaveAccount;

  /// No description provided for @onboardingGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'What brings you here?'**
  String get onboardingGoalsTitle;

  /// No description provided for @onboardingGoalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick any that fit. We\'ll tailor tonight\'s suggestion to match.'**
  String get onboardingGoalsSubtitle;

  /// No description provided for @onboardingGoalsContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingGoalsContinue;

  /// No description provided for @onboardingGoalsSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get onboardingGoalsSkip;

  /// No description provided for @authSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back.'**
  String get authSignInTitle;

  /// No description provided for @authSignUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your\nnight sky.'**
  String get authSignUpTitle;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your stars are waiting.'**
  String get authSignInSubtitle;

  /// No description provided for @authSignUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A quiet companion, always with you.'**
  String get authSignUpSubtitle;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailHint;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordHint;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get authContinueAsGuest;

  /// No description provided for @authAppleSignInError.
  ///
  /// In en, this message translates to:
  /// **'Sign-in was cancelled or failed.'**
  String get authAppleSignInError;

  /// No description provided for @authHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccountPrompt;

  /// No description provided for @authNewPrompt.
  ///
  /// In en, this message translates to:
  /// **'New to Serenity?'**
  String get authNewPrompt;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUp;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetingEvening;

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Let the stars settle.'**
  String get homeHeadline;

  /// No description provided for @homeTonight.
  ///
  /// In en, this message translates to:
  /// **'Tonight\'s meditation'**
  String get homeTonight;

  /// No description provided for @homeQuickStart.
  ///
  /// In en, this message translates to:
  /// **'Quick start'**
  String get homeQuickStart;

  /// No description provided for @scenePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Background scene'**
  String get scenePickerTitle;

  /// No description provided for @sceneLabelOff.
  ///
  /// In en, this message translates to:
  /// **'Voice only'**
  String get sceneLabelOff;

  /// No description provided for @sceneLabelRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get sceneLabelRain;

  /// No description provided for @sceneLabelForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get sceneLabelForest;

  /// No description provided for @sceneLabelWaves.
  ///
  /// In en, this message translates to:
  /// **'Waves'**
  String get sceneLabelWaves;

  /// No description provided for @sceneLabelFire.
  ///
  /// In en, this message translates to:
  /// **'Fireplace'**
  String get sceneLabelFire;

  /// No description provided for @sceneLabelNight.
  ///
  /// In en, this message translates to:
  /// **'Crickets'**
  String get sceneLabelNight;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @libraryHeadline.
  ///
  /// In en, this message translates to:
  /// **'All sessions.'**
  String get libraryHeadline;

  /// No description provided for @librarySearch.
  ///
  /// In en, this message translates to:
  /// **'Search sessions'**
  String get librarySearch;

  /// No description provided for @libraryCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get libraryCategoryAll;

  /// No description provided for @libraryCategorySleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get libraryCategorySleep;

  /// No description provided for @libraryCategoryFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get libraryCategoryFocus;

  /// No description provided for @libraryCategoryStress.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get libraryCategoryStress;

  /// No description provided for @libraryCategoryMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get libraryCategoryMorning;

  /// No description provided for @libraryCategorySoundscapes.
  ///
  /// In en, this message translates to:
  /// **'Soundscapes'**
  String get libraryCategorySoundscapes;

  /// No description provided for @libraryFilterOfflineOnly.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get libraryFilterOfflineOnly;

  /// No description provided for @libraryDetailAbout.
  ///
  /// In en, this message translates to:
  /// **'About this session'**
  String get libraryDetailAbout;

  /// No description provided for @libraryDetailLongDescription.
  ///
  /// In en, this message translates to:
  /// **'A gently paced guided practice led by {narrator}. Settle somewhere comfortable, dim the lights if you can, and let the voice become the landscape for the next {duration}.'**
  String libraryDetailLongDescription(Object narrator, Object duration);

  /// No description provided for @libraryDetailBegin.
  ///
  /// In en, this message translates to:
  /// **'Begin session'**
  String get libraryDetailBegin;

  /// No description provided for @libraryDetailMoreIn.
  ///
  /// In en, this message translates to:
  /// **'More in {category}'**
  String libraryDetailMoreIn(Object category);

  /// No description provided for @libraryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get libraryEmptyTitle;

  /// No description provided for @libraryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try another category — or check back soon.'**
  String get libraryEmptySubtitle;

  /// No description provided for @breatheTitle.
  ///
  /// In en, this message translates to:
  /// **'Breathe'**
  String get breatheTitle;

  /// No description provided for @breatheHeadline.
  ///
  /// In en, this message translates to:
  /// **'Guided patterns.'**
  String get breatheHeadline;

  /// No description provided for @breatheSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a rhythm. Follow the circle. Unwind.'**
  String get breatheSubtitle;

  /// No description provided for @breatheInhale.
  ///
  /// In en, this message translates to:
  /// **'Inhale'**
  String get breatheInhale;

  /// No description provided for @breatheExhale.
  ///
  /// In en, this message translates to:
  /// **'Exhale'**
  String get breatheExhale;

  /// No description provided for @breatheHold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get breatheHold;

  /// No description provided for @breatheReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get breatheReady;

  /// No description provided for @breatheRound.
  ///
  /// In en, this message translates to:
  /// **'Round {n} of {total}'**
  String breatheRound(Object n, Object total);

  /// No description provided for @breatheComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete.'**
  String get breatheComplete;

  /// No description provided for @breatheCompleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notice the quiet that lives just under the breath.'**
  String get breatheCompleteSubtitle;

  /// No description provided for @breatheAgain.
  ///
  /// In en, this message translates to:
  /// **'Breathe again'**
  String get breatheAgain;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @progressHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your quiet hours.'**
  String get progressHeadline;

  /// No description provided for @progressCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get progressCurrentStreak;

  /// No description provided for @progressNightsInARow.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{night in a row} other{nights in a row}}'**
  String progressNightsInARow(num n);

  /// No description provided for @progressTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get progressTotal;

  /// No description provided for @progressSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get progressSessions;

  /// No description provided for @progressLongest.
  ///
  /// In en, this message translates to:
  /// **'Longest'**
  String get progressLongest;

  /// No description provided for @progressLast35Days.
  ///
  /// In en, this message translates to:
  /// **'Last 35 days'**
  String get progressLast35Days;

  /// No description provided for @progressLast35DaysHint.
  ///
  /// In en, this message translates to:
  /// **'Each cell is a day. Brighter means longer.'**
  String get progressLast35DaysHint;

  /// No description provided for @progressAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get progressAchievements;

  /// No description provided for @progressMoodHeading.
  ///
  /// In en, this message translates to:
  /// **'How you\'ve been'**
  String get progressMoodHeading;

  /// No description provided for @progressMoodHint.
  ///
  /// In en, this message translates to:
  /// **'Your check-ins after recent sessions.'**
  String get progressMoodHint;

  /// No description provided for @progressMoodEmpty.
  ///
  /// In en, this message translates to:
  /// **'No check-ins yet. Finish a session to leave one.'**
  String get progressMoodEmpty;

  /// No description provided for @progressThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get progressThisWeek;

  /// No description provided for @progressThisWeekSummary.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{No sessions yet — a quiet week.} =1{1 day of practice · {minutes} min} other{{days} days of practice · {minutes} min}}'**
  String progressThisWeekSummary(num days, num minutes);

  /// No description provided for @progressWeekDeltaUp.
  ///
  /// In en, this message translates to:
  /// **'+{n} min from last week'**
  String progressWeekDeltaUp(num n);

  /// No description provided for @progressWeekDeltaDown.
  ///
  /// In en, this message translates to:
  /// **'{n} min fewer than last week'**
  String progressWeekDeltaDown(num n);

  /// No description provided for @progressWeekDeltaSame.
  ///
  /// In en, this message translates to:
  /// **'Same as last week'**
  String get progressWeekDeltaSame;

  /// No description provided for @progressMoodAverage.
  ///
  /// In en, this message translates to:
  /// **'Average mood {emoji}'**
  String progressMoodAverage(Object emoji);

  /// No description provided for @progressFreezeAvailable.
  ///
  /// In en, this message translates to:
  /// **'1 freeze this week'**
  String get progressFreezeAvailable;

  /// No description provided for @progressFreezeUsed.
  ///
  /// In en, this message translates to:
  /// **'Freeze used this week'**
  String get progressFreezeUsed;

  /// No description provided for @progressFreezeHint.
  ///
  /// In en, this message translates to:
  /// **'One skipped day per week won\'t break your streak.'**
  String get progressFreezeHint;

  /// No description provided for @achievementProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get achievementProgress;

  /// No description provided for @achievementUnitSessions.
  ///
  /// In en, this message translates to:
  /// **'sessions'**
  String get achievementUnitSessions;

  /// No description provided for @achievementUnitDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get achievementUnitDays;

  /// No description provided for @achievementUnitMinutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get achievementUnitMinutes;

  /// No description provided for @achievementRemaining.
  ///
  /// In en, this message translates to:
  /// **'{n} {unit} to go'**
  String achievementRemaining(num n, Object unit);

  /// No description provided for @achievementDescriptionSessions.
  ///
  /// In en, this message translates to:
  /// **'Complete {n} guided sessions — any length, any category. Each one counts toward this badge.'**
  String achievementDescriptionSessions(num n);

  /// No description provided for @achievementDescriptionStreak.
  ///
  /// In en, this message translates to:
  /// **'Meditate on {n} consecutive days. A freeze covers one missed day per week.'**
  String achievementDescriptionStreak(num n);

  /// No description provided for @achievementDescriptionMinutes.
  ///
  /// In en, this message translates to:
  /// **'Accumulate {n} total minutes of practice. Time spent listening — at any speed — counts.'**
  String achievementDescriptionMinutes(num n);

  /// No description provided for @moodSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you feel?'**
  String get moodSheetTitle;

  /// No description provided for @moodSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A quick check-in helps track what works.'**
  String get moodSheetSubtitle;

  /// No description provided for @moodSheetSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get moodSheetSkip;

  /// No description provided for @moodLabel1.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get moodLabel1;

  /// No description provided for @moodLabel2.
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get moodLabel2;

  /// No description provided for @moodLabel3.
  ///
  /// In en, this message translates to:
  /// **'Steady'**
  String get moodLabel3;

  /// No description provided for @moodLabel4.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get moodLabel4;

  /// No description provided for @moodLabel5.
  ///
  /// In en, this message translates to:
  /// **'Radiant'**
  String get moodLabel5;

  /// No description provided for @profileProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get profileProgress;

  /// No description provided for @profileProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Streak, minutes, achievements'**
  String get profileProgressSubtitle;

  /// No description provided for @profilePremium.
  ///
  /// In en, this message translates to:
  /// **'Serenity Premium'**
  String get profilePremium;

  /// No description provided for @profilePremiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock the full library'**
  String get profilePremiumSubtitle;

  /// No description provided for @profilePremiumBadge.
  ///
  /// In en, this message translates to:
  /// **'Free trial'**
  String get profilePremiumBadge;

  /// No description provided for @profilePremiumActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get profilePremiumActive;

  /// No description provided for @profilePremiumTrial.
  ///
  /// In en, this message translates to:
  /// **'Free trial'**
  String get profilePremiumTrial;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications, sound, account'**
  String get profileSettingsSubtitle;

  /// No description provided for @profileHelp.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get profileHelp;

  /// No description provided for @profileHelpLaunchFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the mail app.'**
  String get profileHelpLaunchFailed;

  /// No description provided for @profileAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileAbout;

  /// No description provided for @profileAboutTagline.
  ///
  /// In en, this message translates to:
  /// **'A quiet companion, not a cure. If this practice feels like it\'s helping, let us know.'**
  String get profileAboutTagline;

  /// No description provided for @profileAboutLegalese.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Serenity'**
  String get profileAboutLegalese;

  /// No description provided for @helpFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get helpFaqTitle;

  /// No description provided for @helpContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get helpContactTitle;

  /// No description provided for @helpContactEmail.
  ///
  /// In en, this message translates to:
  /// **'support@serenity.app'**
  String get helpContactEmail;

  /// No description provided for @helpDiagnosticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get helpDiagnosticsTitle;

  /// No description provided for @helpDiagnosticsHint.
  ///
  /// In en, this message translates to:
  /// **'Include this info when reporting a problem'**
  String get helpDiagnosticsHint;

  /// No description provided for @helpDiagnosticsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String helpDiagnosticsVersion(Object version);

  /// No description provided for @helpDiagnosticsLocale.
  ///
  /// In en, this message translates to:
  /// **'Locale {locale}'**
  String helpDiagnosticsLocale(Object locale);

  /// No description provided for @helpFaqQ1.
  ///
  /// In en, this message translates to:
  /// **'Why isn\'t my streak counting up?'**
  String get helpFaqQ1;

  /// No description provided for @helpFaqA1.
  ///
  /// In en, this message translates to:
  /// **'A streak advances when you complete a session on a new day. Extra sessions on the same day do not add another day, and one missed day can be covered by the weekly freeze token for that ISO week.'**
  String get helpFaqA1;

  /// No description provided for @helpFaqQ2.
  ///
  /// In en, this message translates to:
  /// **'How do I change reminder times?'**
  String get helpFaqQ2;

  /// No description provided for @helpFaqA2.
  ///
  /// In en, this message translates to:
  /// **'Open Settings, go to Notifications, and tap the time subtitle on an enabled reminder row to open the time picker.'**
  String get helpFaqA2;

  /// No description provided for @helpFaqQ3.
  ///
  /// In en, this message translates to:
  /// **'Can I listen offline?'**
  String get helpFaqQ3;

  /// No description provided for @helpFaqA3.
  ///
  /// In en, this message translates to:
  /// **'Yes. Tap Download on any library session, then use the Offline filter in the Library to see what is saved on this device.'**
  String get helpFaqA3;

  /// No description provided for @helpFaqQ4.
  ///
  /// In en, this message translates to:
  /// **'How do I switch language or theme?'**
  String get helpFaqQ4;

  /// No description provided for @helpFaqA4.
  ///
  /// In en, this message translates to:
  /// **'Open Settings and look in the Account section for Language and Theme.'**
  String get helpFaqA4;

  /// No description provided for @helpFaqQ5.
  ///
  /// In en, this message translates to:
  /// **'What happens when I delete my account?'**
  String get helpFaqQ5;

  /// No description provided for @helpFaqA5.
  ///
  /// In en, this message translates to:
  /// **'Serenity clears the local progress, reminders, and other saved data on this device. Cloud accounts and sync are not live yet, so there is no remote account data to remove.'**
  String get helpFaqA5;

  /// No description provided for @helpFaqQ6.
  ///
  /// In en, this message translates to:
  /// **'Is this medical advice?'**
  String get helpFaqQ6;

  /// No description provided for @helpFaqA6.
  ///
  /// In en, this message translates to:
  /// **'No. Serenity is a wellness app, not medical care. If you need that reminder again, open the Wellness disclaimer row in Settings.'**
  String get helpFaqA6;

  /// No description provided for @aboutLinkOssLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get aboutLinkOssLicenses;

  /// No description provided for @profileDisplayNameFallback.
  ///
  /// In en, this message translates to:
  /// **'Luna'**
  String get profileDisplayNameFallback;

  /// No description provided for @profileStatStreak.
  ///
  /// In en, this message translates to:
  /// **'streak'**
  String get profileStatStreak;

  /// No description provided for @profileStatDaysShort.
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get profileStatDaysShort;

  /// No description provided for @profileStatMinutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get profileStatMinutes;

  /// No description provided for @profileStatSessions.
  ///
  /// In en, this message translates to:
  /// **'sessions'**
  String get profileStatSessions;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get settingsNotifications;

  /// No description provided for @settingsPlayback.
  ///
  /// In en, this message translates to:
  /// **'PLAYBACK'**
  String get settingsPlayback;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get settingsAccount;

  /// No description provided for @settingsDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get settingsDailyReminder;

  /// No description provided for @settingsDailyReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'9:00 PM'**
  String get settingsDailyReminderSubtitle;

  /// No description provided for @settingsBedtimeReminder.
  ///
  /// In en, this message translates to:
  /// **'Bedtime reminder'**
  String get settingsBedtimeReminder;

  /// No description provided for @settingsBedtimeReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'30 min before sleep'**
  String get settingsBedtimeReminderSubtitle;

  /// No description provided for @settingsHaptic.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get settingsHaptic;

  /// No description provided for @settingsBackgroundAudio.
  ///
  /// In en, this message translates to:
  /// **'Background audio'**
  String get settingsBackgroundAudio;

  /// No description provided for @settingsBackgroundAudioSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Continue when screen is off'**
  String get settingsBackgroundAudioSubtitle;

  /// No description provided for @settingsWifiDownload.
  ///
  /// In en, this message translates to:
  /// **'Download over Wi-Fi only'**
  String get settingsWifiDownload;

  /// No description provided for @settingsProfileRow.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfileRow;

  /// No description provided for @settingsAccountNameFallback.
  ///
  /// In en, this message translates to:
  /// **'Luna'**
  String get settingsAccountNameFallback;

  /// No description provided for @settingsAccountEmailFallback.
  ///
  /// In en, this message translates to:
  /// **'luna@serenity.app'**
  String get settingsAccountEmailFallback;

  /// No description provided for @settingsAccountSummary.
  ///
  /// In en, this message translates to:
  /// **'{name} · {email}'**
  String settingsAccountSummary(Object name, Object email);

  /// No description provided for @settingsSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get settingsSubscription;

  /// No description provided for @settingsSubscriptionPremiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium · active'**
  String get settingsSubscriptionPremiumActive;

  /// No description provided for @settingsSubscriptionFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Free · 14 days left'**
  String get settingsSubscriptionFreeTrial;

  /// No description provided for @settingsWellnessDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Wellness disclaimer'**
  String get settingsWellnessDisclaimer;

  /// No description provided for @settingsCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get settingsCredits;

  /// No description provided for @settingsCreditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get settingsCreditsTitle;

  /// No description provided for @settingsCreditsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No bundled attributions yet'**
  String get settingsCreditsEmptyTitle;

  /// No description provided for @settingsCreditsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'This page will list audio, music, and artwork credits as attribution-required assets land.'**
  String get settingsCreditsEmptySubtitle;

  /// No description provided for @medicalDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t medical advice'**
  String get medicalDisclaimerTitle;

  /// No description provided for @medicalDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'Meditation and breathing practices can support wellbeing, but they are not a substitute for professional care. Serenity is not intended to diagnose, treat, or manage medical or mental health conditions. If distress persists or feels overwhelming, talk to a qualified clinician.'**
  String get medicalDisclaimerBody;

  /// No description provided for @medicalDisclaimerAcknowledge.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get medicalDisclaimerAcknowledge;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get settingsTerms;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get legalPrivacyTitle;

  /// No description provided for @legalTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get legalTermsTitle;

  /// No description provided for @legalLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated {date}'**
  String legalLastUpdated(Object date);

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// No description provided for @settingsSignOutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of Serenity?'**
  String get settingsSignOutDialogTitle;

  /// No description provided for @settingsSignOutDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Your progress and preferences stay on this device. Sign back in anytime to pick up where you left off.'**
  String get settingsSignOutDialogBody;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get settingsLanguageChinese;

  /// No description provided for @settingsLanguageSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get settingsLanguageSheetTitle;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Night sky'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Dawn'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto (time of day)'**
  String get settingsThemeAuto;

  /// No description provided for @settingsThemeSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose theme'**
  String get settingsThemeSheetTitle;

  /// No description provided for @settingsExportData.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get settingsExportData;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your Serenity account?'**
  String get settingsDeleteAccountDialogTitle;

  /// No description provided for @settingsDeleteAccountDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Your progress, streak and preferences on this device will be erased. This action cannot be undone.'**
  String get settingsDeleteAccountDialogBody;

  /// No description provided for @settingsDeleteAccountExportFirst.
  ///
  /// In en, this message translates to:
  /// **'Export then delete'**
  String get settingsDeleteAccountExportFirst;

  /// No description provided for @settingsDeleteAccountExportFirstConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Data exported, account deleted'**
  String get settingsDeleteAccountExportFirstConfirmation;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @settingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// No description provided for @premiumHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Go deeper,\nsleep better.'**
  String get premiumHeroTitle;

  /// No description provided for @premiumHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock the full Serenity library. 14 days free.'**
  String get premiumHeroSubtitle;

  /// No description provided for @premiumBenefit1.
  ///
  /// In en, this message translates to:
  /// **'Unlimited meditations'**
  String get premiumBenefit1;

  /// No description provided for @premiumBenefit2.
  ///
  /// In en, this message translates to:
  /// **'All sleep stories'**
  String get premiumBenefit2;

  /// No description provided for @premiumBenefit3.
  ///
  /// In en, this message translates to:
  /// **'Premium soundscapes'**
  String get premiumBenefit3;

  /// No description provided for @premiumBenefit4.
  ///
  /// In en, this message translates to:
  /// **'New sessions weekly'**
  String get premiumBenefit4;

  /// No description provided for @premiumBenefit5.
  ///
  /// In en, this message translates to:
  /// **'Offline downloads'**
  String get premiumBenefit5;

  /// No description provided for @premiumPlanMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get premiumPlanMonthly;

  /// No description provided for @premiumPlanMonthlyPeriod.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get premiumPlanMonthlyPeriod;

  /// No description provided for @premiumPlanYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get premiumPlanYearly;

  /// No description provided for @premiumPlanYearlyPeriod.
  ///
  /// In en, this message translates to:
  /// **'per year · \$4.99/mo'**
  String get premiumPlanYearlyPeriod;

  /// No description provided for @premiumPlanYearlyBadge.
  ///
  /// In en, this message translates to:
  /// **'Save 50%'**
  String get premiumPlanYearlyBadge;

  /// No description provided for @premiumCta.
  ///
  /// In en, this message translates to:
  /// **'Start 14-day free trial'**
  String get premiumCta;

  /// No description provided for @premiumDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Free for 14 days. Cancel anytime.'**
  String get premiumDisclaimer;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'zh':
      return L10nZh();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
