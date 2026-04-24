/// Validates `docs/content-scripts/*.md` against the editorial/TTS rules.
///
/// Run:
///   dart run tools/validate_scripts.dart
library;

import 'dart:convert';
import 'dart:io';

const _docsDir = 'docs/content-scripts';
final _pausePattern = RegExp(r'\[pause:(\d+)s\]');

// A script may declare its last chunk as trailing silence to be filled
// by the production pipeline. When present, a short explicit reading
// estimate isn't a defect — the audio will play on beyond the last line.
const _trailingSilenceMarkerEn =
    '(silence continues to fill the remaining time)';
const _trailingSilenceMarkerZh = '（剩余时长用静音填满）';
final _medicalClaimPattern = RegExp(
  r'cure|cures|cured|treat|treatment|therapy|diagnose|diagnosis|heal|治愈|疗愈|治疗|诊断',
  caseSensitive: false,
);

class _ScriptDocument {
  const _ScriptDocument({
    required this.path,
    required this.frontmatter,
    required this.sections,
  });

  final String path;
  final Map<String, String> frontmatter;
  final Map<String, String> sections;

  String get fileName => path.split(Platform.pathSeparator).last;
  String get sessionId => frontmatter['session'] ?? fileName;
  bool get isSoundscape => frontmatter['voice'] == 'Soundscape';
}

void main() {
  final files = Directory(_docsDir)
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.md'))
      .where((file) {
        final name = file.uri.pathSegments.last;
        return name != 'README.md' && name != '_briefs.md';
      })
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  var failed = false;
  for (final file in files) {
    final document = _parseDocument(file);
    if (document == null) {
      stderr.writeln('FAIL ${file.path}: could not parse frontmatter/sections');
      failed = true;
      continue;
    }

    final issues = _validate(document);
    if (issues.isEmpty) {
      stdout.writeln('PASS ${document.path}');
      continue;
    }

    failed = true;
    stderr.writeln('FAIL ${document.path}');
    for (final issue in issues) {
      stderr.writeln('  - $issue');
    }
  }

  if (failed) {
    exitCode = 1;
  }
}

_ScriptDocument? _parseDocument(File file) {
  final text = file.readAsStringSync();
  final lines = LineSplitter.split(text).toList();
  if (lines.length < 3 || lines.first.trim() != '---') return null;

  final frontmatter = <String, String>{};
  var index = 1;
  while (index < lines.length && lines[index].trim() != '---') {
    final line = lines[index].trim();
    final colon = line.indexOf(':');
    if (colon > 0) {
      final key = line.substring(0, colon).trim();
      final value = line.substring(colon + 1).trim();
      frontmatter[key] = value;
    }
    index++;
  }
  if (index >= lines.length || lines[index].trim() != '---') return null;

  final sections = <String, String>{};
  String? currentHeading;
  final buffer = <String>[];
  for (final line in lines.skip(index + 1)) {
    if (line.startsWith('## ')) {
      if (currentHeading != null) {
        sections[currentHeading] = buffer.join('\n').trim();
      }
      currentHeading = line.substring(3).trim();
      buffer.clear();
      continue;
    }
    if (currentHeading != null) {
      buffer.add(line);
    }
  }
  if (currentHeading != null) {
    sections[currentHeading] = buffer.join('\n').trim();
  }

  return _ScriptDocument(
    path: file.path,
    frontmatter: frontmatter,
    sections: sections,
  );
}

List<String> _validate(_ScriptDocument document) {
  final issues = <String>[];
  final requiredSections = document.isSoundscape
      ? const ['Brief', 'TTS production notes']
      : const ['Brief', 'Script EN', 'Script ZH', 'TTS production notes'];

  for (final section in requiredSections) {
    final body = document.sections[section];
    if (body == null || body.isEmpty || body == '---') {
      issues.add('missing required section "$section"');
    }
  }

  final durationMinutes = _parseDurationMinutes(document.frontmatter['duration']);
  if (durationMinutes == null) {
    issues.add('frontmatter duration is missing or invalid');
  }

  if (document.isSoundscape) {
    return issues;
  }

  final scriptEn = document.sections['Script EN'];
  final scriptZh = document.sections['Script ZH'];
  if (scriptEn == null || scriptZh == null || scriptEn.isEmpty || scriptZh.isEmpty) {
    return issues;
  }

  final enPauses = _pausePattern.allMatches(scriptEn).map((m) => m.group(1)).toList();
  final zhPauses = _pausePattern.allMatches(scriptZh).map((m) => m.group(1)).toList();
  if (enPauses.length != zhPauses.length) {
    issues.add(
      'pause parity mismatch: EN has ${enPauses.length}, ZH has ${zhPauses.length}',
    );
  } else {
    for (var i = 0; i < enPauses.length; i++) {
      if (enPauses[i] != zhPauses[i]) {
        issues.add(
          'pause parity mismatch at index $i: EN=${enPauses[i]}s ZH=${zhPauses[i]}s',
        );
        break;
      }
    }
  }

  final combinedBody = '$scriptEn\n$scriptZh';
  final medicalMatch = _medicalClaimPattern.firstMatch(combinedBody);
  if (medicalMatch != null) {
    issues.add('medical-claim term found: "${medicalMatch.group(0)}"');
  }

  if (durationMinutes != null) {
    // Scripts may note that the last N seconds are trailing silence —
    // the production pipeline fills the gap to the session's target
    // duration. In that case underrun isn't a defect; only overrun is.
    final hasTrailingSilence = scriptEn.contains(_trailingSilenceMarkerEn) ||
        scriptZh.contains(_trailingSilenceMarkerZh);
    final minMinutes = hasTrailingSilence ? 0.0 : durationMinutes * 0.75;
    final maxMinutes = durationMinutes * 1.25;
    final enEstimate = _estimatedMinutesFor(scriptEn, isZh: false);
    final zhEstimate = _estimatedMinutesFor(scriptZh, isZh: true);
    for (final (label, value) in [
      ('EN', enEstimate),
      ('ZH', zhEstimate),
    ]) {
      if (value < minMinutes || value > maxMinutes) {
        issues.add(
          '$label duration estimate ${value.toStringAsFixed(1)} min '
          'outside ${minMinutes.toStringAsFixed(1)}-${maxMinutes.toStringAsFixed(1)} min',
        );
      }
    }
  }

  return issues;
}

int? _parseDurationMinutes(String? raw) {
  if (raw == null) return null;
  final match = RegExp(r'^(\d+)\s+min$').firstMatch(raw.trim());
  if (match == null) return null;
  return int.tryParse(match.group(1)!);
}

/// Estimate playback duration for ONE language track at 1x speed.
/// Reading rates: 140 EN words/min, 180 ZH chars/min. Pauses add literal
/// seconds regardless of language. The two tracks share the same pause
/// budget by design (beat-aligned), so each is scored independently.
double _estimatedMinutesFor(String script, {required bool isZh}) {
  final pauseSeconds = _pausePattern
      .allMatches(script)
      .map((m) => int.parse(m.group(1)!))
      .fold<int>(0, (sum, seconds) => sum + seconds);
  final pauseMinutes = pauseSeconds / 60.0;
  final withoutPauses = script.replaceAll(_pausePattern, ' ');
  if (isZh) {
    final charCount =
        withoutPauses.replaceAll(RegExp(r'\s+'), '').runes.length;
    return pauseMinutes + charCount / 180.0;
  }
  final wordCount =
      RegExp(r"[A-Za-z0-9']+").allMatches(withoutPauses).length;
  return pauseMinutes + wordCount / 140.0;
}
