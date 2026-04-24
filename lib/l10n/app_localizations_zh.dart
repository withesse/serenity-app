// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class L10nZh extends L10n {
  L10nZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Serenity';

  @override
  String get appTagline => '静心 · 清空';

  @override
  String get commonMinShort => '分钟';

  @override
  String get downloadStart => '下载';

  @override
  String get downloadRemove => '已下载';

  @override
  String get downloadBadge => '离线';

  @override
  String get playerPlay => '播放';

  @override
  String get playerPause => '暂停';

  @override
  String get playerSkipBack15 => '后退 15 秒';

  @override
  String get playerSkipForward15 => '前进 15 秒';

  @override
  String get breatheReadyToBegin => '准备开始';

  @override
  String breatheSemanticsSecondsLeft(Object phase, int seconds) {
    return '$phase，还有 $seconds 秒';
  }

  @override
  String commonDurationMinutes(num n) {
    return '$n 分钟';
  }

  @override
  String get tabHome => '首页';

  @override
  String get tabLibrary => '课程库';

  @override
  String get tabBreathe => '呼吸';

  @override
  String get tabProfile => '我的';

  @override
  String get onboardingTitle => '找到你的\n夜空。';

  @override
  String get onboardingSubtitle => '引导冥想、呼吸和睡眠 — 在星空的静谧之中。';

  @override
  String get onboardingBegin => '开始';

  @override
  String get onboardingHaveAccount => '我已有账户';

  @override
  String get onboardingGoalsTitle => '你希望收获什么？';

  @override
  String get onboardingGoalsSubtitle => '多选即可，我们会据此调整今晚推荐。';

  @override
  String get onboardingGoalsContinue => '继续';

  @override
  String get onboardingGoalsSkip => '暂时跳过';

  @override
  String get authSignInTitle => '欢迎回来。';

  @override
  String get authSignUpTitle => '创建你的\n夜空。';

  @override
  String get authSignInSubtitle => '你的星光在等你。';

  @override
  String get authSignUpSubtitle => '一个始终陪伴你的安静同伴。';

  @override
  String get authEmailHint => '邮箱';

  @override
  String get authPasswordHint => '密码';

  @override
  String get authForgotPassword => '忘记密码？';

  @override
  String get authCreateAccount => '创建账户';

  @override
  String get authSignIn => '登录';

  @override
  String get authContinueAsGuest => '以访客身份继续';

  @override
  String get authAppleSignInError => '登录已取消或失败。';

  @override
  String get authHaveAccountPrompt => '已有账户？';

  @override
  String get authNewPrompt => '初次来到 Serenity？';

  @override
  String get authSignUp => '注册';

  @override
  String get homeGreetingEvening => '晚上好';

  @override
  String get homeHeadline => '让群星安歇。';

  @override
  String get homeTonight => '今晚的冥想';

  @override
  String get homeQuickStart => '快速开始';

  @override
  String get scenePickerTitle => '背景声景';

  @override
  String get sceneLabelOff => '仅人声';

  @override
  String get sceneLabelRain => '雨声';

  @override
  String get sceneLabelForest => '森林';

  @override
  String get sceneLabelWaves => '海浪';

  @override
  String get sceneLabelFire => '壁炉';

  @override
  String get sceneLabelNight => '蟋蟀';

  @override
  String get libraryTitle => '课程库';

  @override
  String get libraryHeadline => '全部课程。';

  @override
  String get librarySearch => '搜索课程';

  @override
  String get libraryCategoryAll => '全部';

  @override
  String get libraryCategorySleep => '睡眠';

  @override
  String get libraryCategoryFocus => '专注';

  @override
  String get libraryCategoryStress => '减压';

  @override
  String get libraryCategoryMorning => '晨起';

  @override
  String get libraryCategorySoundscapes => '声景';

  @override
  String get libraryFilterOfflineOnly => '离线';

  @override
  String get libraryDetailAbout => '关于本次课程';

  @override
  String libraryDetailLongDescription(Object narrator, Object duration) {
    return '由 $narrator 引导的舒缓练习。找一个舒服的位置，若方便请调暗灯光，让声音化作你接下来 $duration 的风景。';
  }

  @override
  String get libraryDetailBegin => '开始本次';

  @override
  String libraryDetailMoreIn(Object category) {
    return '更多 $category';
  }

  @override
  String get libraryEmptyTitle => '这里还没有内容';

  @override
  String get libraryEmptySubtitle => '试试别的分类，或者稍后再来看看。';

  @override
  String get breatheTitle => '呼吸';

  @override
  String get breatheHeadline => '引导节奏。';

  @override
  String get breatheSubtitle => '选一种节奏。跟随圆圈。舒展开来。';

  @override
  String get breatheInhale => '吸气';

  @override
  String get breatheExhale => '呼气';

  @override
  String get breatheHold => '屏息';

  @override
  String get breatheReady => '就绪';

  @override
  String breatheRound(Object n, Object total) {
    return '第 $n 轮，共 $total 轮';
  }

  @override
  String get breatheComplete => '完成。';

  @override
  String get breatheCompleteSubtitle => '留意那藏在呼吸之下的宁静。';

  @override
  String get breatheAgain => '再来一次';

  @override
  String get progressTitle => '进度';

  @override
  String get progressHeadline => '你的静谧时光。';

  @override
  String get progressCurrentStreak => '当前连续';

  @override
  String progressNightsInARow(num n) {
    return '连续 $n 晚';
  }

  @override
  String get progressTotal => '总计';

  @override
  String get progressSessions => '次数';

  @override
  String get progressLongest => '最长';

  @override
  String get progressLast35Days => '最近 35 天';

  @override
  String get progressLast35DaysHint => '每格一天，越亮时间越长。';

  @override
  String get progressAchievements => '成就';

  @override
  String get progressMoodHeading => '近期心情';

  @override
  String get progressMoodHint => '最近练习后的记录。';

  @override
  String get progressMoodEmpty => '还没有记录。完成一次练习来留下一笔。';

  @override
  String get progressThisWeek => '本周';

  @override
  String progressThisWeekSummary(num days, num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '练习 $days 天 · $minutes 分钟',
      zero: '还没有练习 — 安静的一周。',
    );
    return '$_temp0';
  }

  @override
  String progressWeekDeltaUp(num n) {
    return '比上周多 $n 分钟';
  }

  @override
  String progressWeekDeltaDown(num n) {
    return '比上周少 $n 分钟';
  }

  @override
  String get progressWeekDeltaSame => '与上周持平';

  @override
  String progressMoodAverage(Object emoji) {
    return '平均心情 $emoji';
  }

  @override
  String get progressFreezeAvailable => '本周有 1 次冻结';

  @override
  String get progressFreezeUsed => '本周冻结已使用';

  @override
  String get progressFreezeHint => '每周漏一天不会中断连续。';

  @override
  String get achievementProgress => '进度';

  @override
  String get achievementUnitSessions => '次';

  @override
  String get achievementUnitDays => '天';

  @override
  String get achievementUnitMinutes => '分钟';

  @override
  String achievementRemaining(num n, Object unit) {
    return '还差 $n $unit';
  }

  @override
  String achievementDescriptionSessions(num n) {
    return '完成 $n 次引导练习——任意时长、任意类别，每一次都算。';
  }

  @override
  String achievementDescriptionStreak(num n) {
    return '连续冥想 $n 天。每周一次冻结可豁免一个漏掉的日子。';
  }

  @override
  String achievementDescriptionMinutes(num n) {
    return '累计 $n 分钟练习。任意速度下的收听时长都计入。';
  }

  @override
  String get moodSheetTitle => '现在感觉怎样？';

  @override
  String get moodSheetSubtitle => '轻轻记一笔，帮你看见什么真正有效。';

  @override
  String get moodSheetSkip => '跳过';

  @override
  String get moodLabel1 => '沉重';

  @override
  String get moodLabel2 => '疲惫';

  @override
  String get moodLabel3 => '平稳';

  @override
  String get moodLabel4 => '安定';

  @override
  String get moodLabel5 => '通透';

  @override
  String get profileProgress => '进度';

  @override
  String get profileProgressSubtitle => '连续、时长、成就';

  @override
  String get profilePremium => 'Serenity 会员';

  @override
  String get profilePremiumSubtitle => '解锁完整课程库';

  @override
  String get profilePremiumBadge => '免费试用';

  @override
  String get profilePremiumActive => '已开通';

  @override
  String get profilePremiumTrial => '免费试用';

  @override
  String get profileSettings => '设置';

  @override
  String get profileSettingsSubtitle => '通知、声音、账号';

  @override
  String get profileHelp => '帮助与支持';

  @override
  String get profileHelpLaunchFailed => '无法打开邮件应用。';

  @override
  String get profileAbout => '关于';

  @override
  String get profileAboutTagline => '安静的同伴，不是治疗。若这份练习对你有帮助，欢迎告诉我们。';

  @override
  String get profileAboutLegalese => '© 2026 Serenity';

  @override
  String get helpFaqTitle => '常见问题';

  @override
  String get helpContactTitle => '联系我们';

  @override
  String get helpContactEmail => 'support@serenity.app';

  @override
  String get helpDiagnosticsTitle => '诊断信息';

  @override
  String get helpDiagnosticsHint => '反馈问题时请附上这些信息';

  @override
  String helpDiagnosticsVersion(Object version) {
    return '版本 $version';
  }

  @override
  String helpDiagnosticsLocale(Object locale) {
    return '语言环境 $locale';
  }

  @override
  String get helpFaqQ1 => '为什么我的连续天数没有增加？';

  @override
  String get helpFaqA1 =>
      '只有完成一次课程后，新的自然日才会让连续天数增加。同一天内重复练习不会多算一天，而每个 ISO 周的一次漏掉日期可以由每周冻结补上。';

  @override
  String get helpFaqQ2 => '怎么修改提醒时间？';

  @override
  String get helpFaqA2 => '打开设置，进入通知分组，然后点按已开启提醒那一行里的时间副标题，就会打开时间选择器。';

  @override
  String get helpFaqQ3 => '可以离线收听吗？';

  @override
  String get helpFaqA3 => '可以。先在任意课程上点下载，再到课程库里使用“离线”筛选，就能看到已保存在这台设备上的内容。';

  @override
  String get helpFaqQ4 => '怎么切换语言或主题？';

  @override
  String get helpFaqA4 => '打开设置，在账号分组里可以找到语言和主题。';

  @override
  String get helpFaqQ5 => '删除账号后会发生什么？';

  @override
  String get helpFaqA5 =>
      'Serenity 会清除这台设备上的本地进度、提醒和其他已保存数据。云端账号和同步目前还没有上线，所以没有远端数据需要删除。';

  @override
  String get helpFaqQ6 => '这算医疗建议吗？';

  @override
  String get helpFaqA6 =>
      '不算。Serenity 是健康练习应用，不是医疗服务。如果你想再次查看这条提醒，可以到设置里的“健康提示”。';

  @override
  String get aboutLinkOssLicenses => '开源许可';

  @override
  String get profileDisplayNameFallback => 'Luna';

  @override
  String get profileStatStreak => '连续';

  @override
  String get profileStatDaysShort => '天';

  @override
  String get profileStatMinutes => '分钟';

  @override
  String get profileStatSessions => '次数';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsPlayback => '播放';

  @override
  String get settingsAccount => '账号';

  @override
  String get settingsDailyReminder => '每日提醒';

  @override
  String get settingsDailyReminderSubtitle => '21:00';

  @override
  String get settingsBedtimeReminder => '睡前提醒';

  @override
  String get settingsBedtimeReminderSubtitle => '睡前 30 分钟';

  @override
  String get settingsHaptic => '触觉反馈';

  @override
  String get settingsBackgroundAudio => '后台播放';

  @override
  String get settingsBackgroundAudioSubtitle => '锁屏后继续播放';

  @override
  String get settingsWifiDownload => '仅 Wi-Fi 下载';

  @override
  String get settingsProfileRow => '账户';

  @override
  String get settingsAccountNameFallback => 'Luna';

  @override
  String get settingsAccountEmailFallback => 'luna@serenity.app';

  @override
  String settingsAccountSummary(Object name, Object email) {
    return '$name · $email';
  }

  @override
  String get settingsSubscription => '订阅';

  @override
  String get settingsSubscriptionPremiumActive => '会员 · 已开通';

  @override
  String get settingsSubscriptionFreeTrial => '免费版 · 剩余 14 天';

  @override
  String get settingsWellnessDisclaimer => '健康提示';

  @override
  String get settingsCredits => '致谢与版权';

  @override
  String get settingsCreditsTitle => '致谢与版权';

  @override
  String get settingsCreditsEmptyTitle => '暂时还没有内置素材致谢';

  @override
  String get settingsCreditsEmptySubtitle =>
      '当需要署名的音频、音乐或美术资源进入应用后，这里会列出对应的来源与版权信息。';

  @override
  String get medicalDisclaimerTitle => '请知悉：这不是医疗建议';

  @override
  String get medicalDisclaimerBody =>
      '冥想和呼吸练习可以帮助日常放松与照料自己，但不能替代专业照护。Serenity 无意用于诊断、治疗或管理任何身体或心理状况。如果不适或痛苦持续存在，或让你难以承受，请联系合格的临床专业人士。';

  @override
  String get medicalDisclaimerAcknowledge => '我明白';

  @override
  String get settingsPrivacy => '隐私';

  @override
  String get settingsTerms => '条款';

  @override
  String get legalPrivacyTitle => '隐私';

  @override
  String get legalTermsTitle => '条款';

  @override
  String legalLastUpdated(Object date) {
    return '最后更新 $date';
  }

  @override
  String get settingsSignOut => '退出登录';

  @override
  String get settingsSignOutDialogTitle => '退出 Serenity？';

  @override
  String get settingsSignOutDialogBody => '你的进度和偏好仍保留在这台设备上，随时可以再登回来继续。';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageSystem => '跟随系统';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageChinese => '中文';

  @override
  String get settingsLanguageSheetTitle => '选择语言';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsThemeDark => '星夜';

  @override
  String get settingsThemeLight => '黎明';

  @override
  String get settingsThemeAuto => '自动（跟随时间）';

  @override
  String get settingsThemeSheetTitle => '选择主题';

  @override
  String get settingsExportData => '导出我的数据';

  @override
  String get settingsDeleteAccount => '删除账号';

  @override
  String get settingsDeleteAccountDialogTitle => '删除你的 Serenity 账号？';

  @override
  String get settingsDeleteAccountDialogBody => '此设备上的进度、连续天数和偏好将被清除，操作不可撤销。';

  @override
  String get settingsDeleteAccountExportFirst => '先导出再删除';

  @override
  String get settingsDeleteAccountExportFirstConfirmation => '数据已导出，账号已删除';

  @override
  String get settingsDeleteAccountConfirm => '删除';

  @override
  String get settingsCancel => '取消';

  @override
  String get premiumHeroTitle => '更深入，\n睡得更好。';

  @override
  String get premiumHeroSubtitle => '解锁完整 Serenity 课程库，14 天免费。';

  @override
  String get premiumBenefit1 => '无限冥想课程';

  @override
  String get premiumBenefit2 => '全部睡眠故事';

  @override
  String get premiumBenefit3 => '高阶声景';

  @override
  String get premiumBenefit4 => '每周新增课程';

  @override
  String get premiumBenefit5 => '离线下载';

  @override
  String get premiumPlanMonthly => '月度';

  @override
  String get premiumPlanMonthlyPeriod => '每月';

  @override
  String get premiumPlanYearly => '年度';

  @override
  String get premiumPlanYearlyPeriod => '每年 · 每月 ¥29';

  @override
  String get premiumPlanYearlyBadge => '省 50%';

  @override
  String get premiumCta => '开启 14 天免费试用';

  @override
  String get premiumDisclaimer => '14 天免费，随时取消。';
}
