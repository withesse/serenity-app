import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Per-session text presented to the user. `LibrarySession` keeps the
/// canonical English copy in its constructor; `localized()` picks up the
/// Chinese overrides from [_zhSessions] when the app locale is zh.
typedef LocalizedSessionText = ({String title, String narrator, String tagline});

enum LibraryCategory { all, sleep, focus, stress, morning, soundscapes }

extension LibraryCategoryLabel on LibraryCategory {
  /// English-only fallback. Prefer [labelLocalized] where an L10n is in scope.
  String get label => switch (this) {
        LibraryCategory.all => 'All',
        LibraryCategory.sleep => 'Sleep',
        LibraryCategory.focus => 'Focus',
        LibraryCategory.stress => 'Stress',
        LibraryCategory.morning => 'Morning',
        LibraryCategory.soundscapes => 'Soundscapes',
      };

  String labelLocalized(L10n l) => switch (this) {
        LibraryCategory.all => l.libraryCategoryAll,
        LibraryCategory.sleep => l.libraryCategorySleep,
        LibraryCategory.focus => l.libraryCategoryFocus,
        LibraryCategory.stress => l.libraryCategoryStress,
        LibraryCategory.morning => l.libraryCategoryMorning,
        LibraryCategory.soundscapes => l.libraryCategorySoundscapes,
      };
}

@immutable
class LibrarySession {
  const LibrarySession({
    required this.id,
    required this.title,
    required this.narrator,
    required this.duration,
    required this.category,
    required this.tagline,
    required this.gradient,
  });

  final String id;
  final String title;
  final String narrator;
  final Duration duration;
  final LibraryCategory category;
  final String tagline;
  final List<Color> gradient;

  /// English-only label used where an L10n is not conveniently in scope
  /// (share text, lockscreen subtitle, tests). UI surfaces should prefer
  /// [durationLabelFor].
  String get durationLabel => '${duration.inMinutes} min';

  String durationLabelFor(L10n l) => l.commonDurationMinutes(duration.inMinutes);

  /// Returns the English originals unless [locale] is Chinese, in which
  /// case we swap in translated strings by id. Sessions without a zh
  /// override keep their English copy — safer than rendering an empty
  /// label for a newly-added session that hasn't been translated yet.
  LocalizedSessionText localized(Locale? locale) {
    if (locale?.languageCode == 'zh') {
      final t = _zhSessions[id];
      if (t != null) return t;
    }
    return (title: title, narrator: narrator, tagline: tagline);
  }
}

/// Chinese translations for every session in [librarySessions]. Narrator
/// personal names (Mei, Aya, Felix, Noah) stay in Latin script — they
/// identify real people, not concepts. Only the generic "Soundscape"
/// attribution gets translated.
const Map<String, LocalizedSessionText> _zhSessions = {
  'drifting-into-stillness': (
    title: '缓缓入静',
    narrator: 'Mei',
    tagline: '让身体柔和地融入夜色。',
  ),
  'deep-sleep-story': (
    title: '午夜港湾',
    narrator: 'Felix',
    tagline: '一段缓慢的故事，引你沉入深眠。',
  ),
  'focus-flow': (
    title: '澄明专注',
    narrator: 'Aya',
    tagline: '收拢注意力，稳住心流。',
  ),
  'deep-work': (
    title: '深度工作预热',
    narrator: 'Noah',
    tagline: '在长时专注之前，先把心安下来。',
  ),
  'unwind-stress': (
    title: '松解紧张',
    narrator: 'Mei',
    tagline: '把一整天紧握的东西放下。',
  ),
  'morning-light': (
    title: '初光',
    narrator: 'Aya',
    tagline: '以一片开阔的天空开启一天。',
  ),
  'rain-under-eaves': (
    title: '屋檐下的雨',
    narrator: '声景',
    tagline: '落在屋顶的细雨，无人声。',
  ),
  'forest-at-dusk': (
    title: '暮色森林',
    narrator: '声景',
    tagline: '蟋蟀、远处的夜枭、簌簌落叶。',
  ),
};

// Accent gradients — variations inside the nightly palette.
const _deepSleep = [Color(0xFF2D1B4E), Color(0xFF1A1B3A)];
const _focus = [Color(0xFF1E3A8A), Color(0xFF6366F1)];
const _stress = [Color(0xFF3B2C5A), Color(0xFFA855F7)];
const _morning = [Color(0xFF6B5FD9), Color(0xFFE8C547)];
const _sound = [Color(0xFF0B1426), Color(0xFF6B5FD9)];

const librarySessions = <LibrarySession>[
  LibrarySession(
    id: 'drifting-into-stillness',
    title: 'Drifting into Stillness',
    narrator: 'Mei',
    duration: Duration(minutes: 10),
    category: LibraryCategory.sleep,
    tagline: 'Let the body soften into the night.',
    gradient: _deepSleep,
  ),
  LibrarySession(
    id: 'deep-sleep-story',
    title: 'Midnight Harbour',
    narrator: 'Felix',
    duration: Duration(minutes: 25),
    category: LibraryCategory.sleep,
    tagline: 'A slow story to drift you into deep rest.',
    gradient: _deepSleep,
  ),
  LibrarySession(
    id: 'focus-flow',
    title: 'Clear Mind Focus',
    narrator: 'Aya',
    duration: Duration(minutes: 12),
    category: LibraryCategory.focus,
    tagline: 'Centre attention, steady the current.',
    gradient: _focus,
  ),
  LibrarySession(
    id: 'deep-work',
    title: 'Deep Work Warmup',
    narrator: 'Noah',
    duration: Duration(minutes: 8),
    category: LibraryCategory.focus,
    tagline: 'Prime the mind before a long session.',
    gradient: _focus,
  ),
  LibrarySession(
    id: 'unwind-stress',
    title: 'Unwind the Spiral',
    narrator: 'Mei',
    duration: Duration(minutes: 15),
    category: LibraryCategory.stress,
    tagline: 'Release what has been held all day.',
    gradient: _stress,
  ),
  LibrarySession(
    id: 'morning-light',
    title: 'First Light',
    narrator: 'Aya',
    duration: Duration(minutes: 7),
    category: LibraryCategory.morning,
    tagline: 'Start the day with an open sky.',
    gradient: _morning,
  ),
  LibrarySession(
    id: 'rain-under-eaves',
    title: 'Rain Under Eaves',
    narrator: 'Soundscape',
    duration: Duration(minutes: 60),
    category: LibraryCategory.soundscapes,
    tagline: 'Steady rain on a tin roof. No voice.',
    gradient: _sound,
  ),
  LibrarySession(
    id: 'forest-at-dusk',
    title: 'Forest at Dusk',
    narrator: 'Soundscape',
    duration: Duration(minutes: 60),
    category: LibraryCategory.soundscapes,
    tagline: 'Crickets, distant owl, settling leaves.',
    gradient: _sound,
  ),
];

LibrarySession? findSession(String id) {
  for (final s in librarySessions) {
    if (s.id == id) return s;
  }
  return null;
}

/// Convenience helper — used by the gold featured tile on Home.
const featuredSessionId = 'drifting-into-stillness';

/// Time-of-day pick for the Home hero card. Morning gets a morning session,
/// afternoon leans into focus, early evening unwinds stress, night prepares
/// sleep. If the user has set onboarding [goals] and the hour's category
/// isn't among them, we fall through to any matching goal so the home card
/// stays relevant to why the user installed the app. Falls back to the
/// featured session if nothing matches.
LibrarySession tonightRecommendation({
  DateTime? now,
  Set<LibraryCategory> goals = const {},
}) {
  final hour = (now ?? DateTime.now()).hour;
  final LibraryCategory hourTarget;
  if (hour >= 5 && hour < 11) {
    hourTarget = LibraryCategory.morning;
  } else if (hour >= 11 && hour < 17) {
    hourTarget = LibraryCategory.focus;
  } else if (hour >= 17 && hour < 21) {
    hourTarget = LibraryCategory.stress;
  } else {
    hourTarget = LibraryCategory.sleep;
  }
  final targets = <LibraryCategory>[
    if (goals.isEmpty || goals.contains(hourTarget)) hourTarget,
    ...goals.where((g) => g != hourTarget),
    hourTarget,
  ];
  for (final target in targets) {
    for (final s in librarySessions) {
      if (s.category == target) return s;
    }
  }
  return findSession(featuredSessionId) ?? librarySessions.first;
}
