/// Renders narrated session scripts in `docs/content-scripts/*.md` to mp3.
///
/// Usage:
///   GOOGLE_CLOUD_TTS_KEY=your-api-key dart run tools/tts_render.dart
///   GOOGLE_CLOUD_TTS_KEY=your-api-key dart run tools/tts_render.dart --only deep-work --locale zh
///   dart run tools/tts_render.dart --dry-run
///
/// Narrated sessions produce `assets/audio/<session-id>.<en|zh>.mp3`.
/// Soundscape entries are skipped because they intentionally have no script body.
library;

import 'dart:convert';
import 'dart:io';

const _docsDir = 'docs/content-scripts';
const _audioDir = 'assets/audio';
const _ttsEndpoint = 'https://texttospeech.googleapis.com/v1/text:synthesize';

enum _ScriptLocale {
  en('en', 'en-US', 'en-US-Neural2-F'),
  zh('zh', 'cmn-CN', 'cmn-CN-Standard-A');

  const _ScriptLocale(this.code, this.languageCode, this.defaultVoice);

  final String code;
  final String languageCode;
  final String defaultVoice;
}

class _CliOptions {
  const _CliOptions({
    required this.dryRun,
    required this.onlySessionId,
    required this.locales,
  });

  final bool dryRun;
  final String? onlySessionId;
  final List<_ScriptLocale> locales;
}

class _ScriptDocument {
  const _ScriptDocument({
    required this.path,
    required this.frontmatter,
    required this.sections,
  });

  final String path;
  final Map<String, String> frontmatter;
  final Map<String, String> sections;

  String get sessionId => frontmatter['session'] ?? '';
  String? get voice => frontmatter['voice'];
}

Future<int> main(List<String> args) async {
  final options = _parseArgs(args);
  if (options == null) return 64;

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

  var hadFailure = false;
  var matchedAny = false;
  for (final file in files) {
    final document = _parseDocument(file);
    if (document == null) {
      stderr.writeln('warn: failed to parse ${file.path}');
      hadFailure = true;
      continue;
    }
    if (options.onlySessionId != null &&
        document.sessionId != options.onlySessionId) {
      continue;
    }
    matchedAny = true;
    final result = await _renderDocument(document, options);
    hadFailure = hadFailure || !result;
  }

  if (options.onlySessionId != null && !matchedAny) {
    stderr.writeln('error: no script matched session "${options.onlySessionId}"');
    return 1;
  }

  return hadFailure ? 1 : 0;
}

_CliOptions? _parseArgs(List<String> args) {
  var dryRun = false;
  String? onlySessionId;
  var locales = _ScriptLocale.values.toList(growable: false);

  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    switch (arg) {
      case '--dry-run':
        dryRun = true;
      case '--only':
        if (i + 1 >= args.length) {
          _printUsage('missing value for --only');
          return null;
        }
        onlySessionId = args[++i];
      case '--locale':
        if (i + 1 >= args.length) {
          _printUsage('missing value for --locale');
          return null;
        }
        final raw = args[++i];
        switch (raw) {
          case 'all':
            locales = _ScriptLocale.values.toList(growable: false);
          case 'en':
            locales = const [_ScriptLocale.en];
          case 'zh':
            locales = const [_ScriptLocale.zh];
          default:
            _printUsage('invalid locale "$raw"');
            return null;
        }
      case '--help':
      case '-h':
        _printUsage();
        return null;
      default:
        _printUsage('unknown flag "$arg"');
        return null;
    }
  }

  return _CliOptions(
    dryRun: dryRun,
    onlySessionId: onlySessionId,
    locales: locales,
  );
}

void _printUsage([String? error]) {
  if (error != null) {
    stderr.writeln('error: $error');
  }
  stdout.writeln(
    'Usage: dart run tools/tts_render.dart [--dry-run] [--only <session-id>] '
    '[--locale en|zh|all]',
  );
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
        sections[currentHeading] = _normalizeSection(buffer);
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
    sections[currentHeading] = _normalizeSection(buffer);
  }

  return _ScriptDocument(
    path: file.path,
    frontmatter: frontmatter,
    sections: sections,
  );
}

String _normalizeSection(List<String> lines) {
  final normalized = lines.join('\n').trim();
  return normalized == '---' ? '' : normalized;
}

Future<bool> _renderDocument(
  _ScriptDocument document,
  _CliOptions options,
) async {
  if (document.voice == 'Soundscape') {
    stdout.writeln('skip: ${document.sessionId} (Soundscape)');
    return true;
  }

  final scripts = {
    _ScriptLocale.en: document.sections['Script EN'],
    _ScriptLocale.zh: document.sections['Script ZH'],
  };

  var ok = true;
  for (final locale in options.locales) {
    final body = scripts[locale];
    if (body == null || body.trim().isEmpty) {
      stderr.writeln(
        'warn: ${document.sessionId} missing ${locale.code.toUpperCase()} script in ${document.path}',
      );
      ok = false;
      continue;
    }

    final ssml = _scriptToSsml(body);
    final targetPath = '$_audioDir/${document.sessionId}.${locale.code}.mp3';
    if (options.dryRun) {
      stdout.writeln(
        'dry-run: session=${document.sessionId} locale=${locale.code} '
        'target=$targetPath ssml_chars=${ssml.length}',
      );
      continue;
    }

    final apiKey = Platform.environment['GOOGLE_CLOUD_TTS_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      stderr.writeln(
        'error: GOOGLE_CLOUD_TTS_KEY is not set; cannot render ${document.sessionId}.${locale.code}',
      );
      return false;
    }

    final voiceName = _voiceNameFor(document, locale);
    final requestBody = {
      'input': {'ssml': ssml},
      'voice': {
        'languageCode': locale.languageCode,
        'name': voiceName,
      },
      'audioConfig': {'audioEncoding': 'MP3'},
    };

    try {
      final audioBytes = await _synthesize(requestBody, apiKey: apiKey);
      final target = File(targetPath);
      await target.parent.create(recursive: true);
      await target.writeAsBytes(audioBytes);
      stdout.writeln(
        'rendered: session=${document.sessionId} locale=${locale.code} target=$targetPath voice=$voiceName',
      );
    } catch (error) {
      stderr.writeln(
        'error: failed to render ${document.sessionId}.${locale.code}: $error',
      );
      ok = false;
    }
  }
  return ok;
}

String _voiceNameFor(_ScriptDocument document, _ScriptLocale locale) {
  final configured = document.voice?.trim();
  if (configured == null || configured.isEmpty) {
    return locale.defaultVoice;
  }
  if (configured == 'Soundscape') {
    return configured;
  }

  // Editorial files currently store narrator labels (Mei / Aya / Felix / Noah)
  // rather than Google voice ids. If a real Google voice id is added later,
  // use it directly; otherwise fall back to the locale default.
  final looksLikeGoogleVoice =
      configured.contains('Neural') || configured.contains('Standard');
  return looksLikeGoogleVoice ? configured : locale.defaultVoice;
}

String _scriptToSsml(String script) {
  final escaped = const LineSplitter()
      .convert(script.trim())
      .map(_escapeXml)
      .join('\n');
  final withBreaks = escaped.replaceAllMapped(
    RegExp(r'\[pause:(\d+)s\]'),
    (match) => '<break time="${match.group(1)}s"/>',
  );
  return '<speak>$withBreaks</speak>';
}

String _escapeXml(String raw) {
  return raw
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}

Future<List<int>> _synthesize(
  Map<String, Object?> requestBody, {
  required String apiKey,
}) async {
  final client = HttpClient();
  try {
    final uri = Uri.parse('$_ttsEndpoint?key=$apiKey');
    final request = await client.postUrl(uri);
    request.headers.contentType = ContentType.json;
    request.add(utf8.encode(jsonEncode(requestBody)));
    final response = await request.close();
    final payload = await utf8.decodeStream(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'HTTP ${response.statusCode}: $payload',
        uri: uri,
      );
    }
    final decoded = jsonDecode(payload) as Map<String, dynamic>;
    final audioContent = decoded['audioContent'];
    if (audioContent is! String || audioContent.isEmpty) {
      throw const FormatException('missing audioContent in TTS response');
    }
    return base64Decode(audioContent);
  } finally {
    client.close(force: true);
  }
}
