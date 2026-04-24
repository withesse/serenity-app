import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

enum BreathPhase { inhale, holdFull, exhale, holdEmpty }

typedef LocalizedTechniqueText = ({String name, String tagline});

extension BreathPhaseLabel on BreathPhase {
  String get label => switch (this) {
        BreathPhase.inhale => 'Inhale',
        BreathPhase.holdFull => 'Hold',
        BreathPhase.exhale => 'Exhale',
        BreathPhase.holdEmpty => 'Hold',
      };

  String labelLocalized(L10n l) => switch (this) {
        BreathPhase.inhale => l.breatheInhale,
        BreathPhase.holdFull || BreathPhase.holdEmpty => l.breatheHold,
        BreathPhase.exhale => l.breatheExhale,
      };
}

@immutable
class BreathStep {
  const BreathStep(this.phase, this.seconds);
  final BreathPhase phase;
  final int seconds;
}

@immutable
class BreathingTechnique {
  const BreathingTechnique({
    required this.id,
    required this.name,
    required this.tagline,
    required this.steps,
    required this.rounds,
  });

  final String id;
  final String name;
  final String tagline;
  final List<BreathStep> steps;
  final int rounds;

  /// Compact pattern string, e.g. "4 · 4 · 4 · 4".
  String get pattern => steps.map((s) => s.seconds).join(' · ');

  /// Total seconds for one full cycle.
  int get cycleSeconds =>
      steps.fold<int>(0, (sum, s) => sum + s.seconds);

  int get durationMinutes => (cycleSeconds * rounds / 60).ceil();

  /// English-only fallback. Prefer the `commonDurationMinutes` l10n at UI sites.
  String get durationLabel => '$durationMinutes min';

  LocalizedTechniqueText localized(Locale? locale) {
    if (locale?.languageCode == 'zh') {
      final t = _zhTechniques[id];
      if (t != null) return t;
    }
    return (name: name, tagline: tagline);
  }
}

const Map<String, LocalizedTechniqueText> _zhTechniques = {
  'box': (
    name: '方盒呼吸',
    tagline: '安抚神经系统，收拢注意力。',
  ),
  'four-seven-eight': (
    name: '4-7-8 呼吸',
    tagline: '放慢心跳，邀请睡意。',
  ),
  'coherent': (
    name: '协同呼吸',
    tagline: '每分钟五次，让心与脑回到平衡。',
  ),
  'deep-calm': (
    name: '深度安定',
    tagline: '延长呼气，深深放松。',
  ),
};

const breathingTechniques = <BreathingTechnique>[
  BreathingTechnique(
    id: 'box',
    name: 'Box Breathing',
    tagline: 'Calm the nervous system, centre focus.',
    steps: [
      BreathStep(BreathPhase.inhale, 4),
      BreathStep(BreathPhase.holdFull, 4),
      BreathStep(BreathPhase.exhale, 4),
      BreathStep(BreathPhase.holdEmpty, 4),
    ],
    rounds: 8,
  ),
  BreathingTechnique(
    id: 'four-seven-eight',
    name: '4-7-8 Relaxing',
    tagline: 'Slow the pulse, invite sleep.',
    steps: [
      BreathStep(BreathPhase.inhale, 4),
      BreathStep(BreathPhase.holdFull, 7),
      BreathStep(BreathPhase.exhale, 8),
    ],
    rounds: 6,
  ),
  BreathingTechnique(
    id: 'coherent',
    name: 'Coherent Breathing',
    tagline: 'Five per minute. Balance heart & mind.',
    steps: [
      BreathStep(BreathPhase.inhale, 6),
      BreathStep(BreathPhase.exhale, 6),
    ],
    rounds: 10,
  ),
  BreathingTechnique(
    id: 'deep-calm',
    name: 'Deep Calm',
    tagline: 'Long exhale. Deep release.',
    steps: [
      BreathStep(BreathPhase.inhale, 4),
      BreathStep(BreathPhase.holdFull, 2),
      BreathStep(BreathPhase.exhale, 8),
    ],
    rounds: 8,
  ),
];
