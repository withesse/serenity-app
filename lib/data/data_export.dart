import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'analytics.dart';
import 'crash_reporter.dart';

/// Builds a JSON dump of every Hive box the app uses and hands it off to
/// the system share sheet. Satisfies the "export my data" obligation that
/// comes with GDPR / CCPA / Apple App Privacy — everything we persist is
/// included so the user can read, archive, or port it elsewhere.
///
/// Boxes in use — keep this list in sync with [main.dart] openBox calls:
///   - `settings` : preferences, reminders, theme, language, profile
///   - `progress` : streak, totals, day-by-day minutes, moods, freeze
const _boxes = ['settings', 'progress'];

/// Builds the export payload. Kept pure so tests can assert on it without
/// exercising share_plus.
Map<String, dynamic> buildExportPayload({DateTime? at}) {
  final boxes = <String, Map<String, dynamic>>{};
  for (final name in _boxes) {
    if (!Hive.isBoxOpen(name)) continue;
    final box = Hive.box<dynamic>(name);
    final entries = <String, dynamic>{};
    for (final key in box.keys) {
      entries['$key'] = _safe(box.get(key));
    }
    boxes[name] = entries;
  }
  return {
    'app': 'serenity',
    'exportedAt': (at ?? DateTime.now().toUtc()).toIso8601String(),
    'schema': 1,
    'boxes': boxes,
  };
}

/// Hive stores a handful of Flutter-specific types (TimeOfDay surrogate,
/// nested List) that JSON encoding can't take raw. Walk the tree and
/// normalise to strings/lists/maps before handing to [jsonEncode].
Object? _safe(Object? raw) {
  if (raw == null || raw is String || raw is num || raw is bool) return raw;
  if (raw is List) return raw.map(_safe).toList();
  if (raw is Map) {
    return raw.map((k, v) => MapEntry(k.toString(), _safe(v)));
  }
  return raw.toString();
}

/// Writes the payload to a temp file and triggers the system share sheet.
/// The file is left in the app's temp directory so the OS can clean it up.
Future<void> exportUserData(BuildContext context) async {
  // Capture the render box before awaiting — BuildContext across async gaps
  // is unsafe, but RenderBox snapshots the geometry at call time.
  final box = context.findRenderObject() as RenderBox?;
  final origin = box != null
      ? box.localToGlobal(Offset.zero) & box.size
      : null;
  final container = ProviderScope.containerOf(context, listen: false);
  final analytics = container.read(analyticsProvider);
  final crashReporter = container.read(crashReporterProvider);

  final payload = buildExportPayload();
  final json = const JsonEncoder.withIndent('  ').convert(payload);
  final dir = await getTemporaryDirectory();
  final stamp = DateTime.now()
      .toIso8601String()
      .replaceAll(':', '-')
      .split('.')
      .first;
  final file = File('${dir.path}/serenity-export-$stamp.json');
  await file.writeAsString(json);

  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path, mimeType: 'application/json')],
      subject: 'Serenity data export',
      sharePositionOrigin: origin,
    ),
  );
  await analytics.track(
    AnalyticsEvents.dataExported,
    {'path': file.path},
  );
  await crashReporter.breadcrumb(
    AnalyticsEvents.dataExported,
    data: {'path': file.path},
  );
}
