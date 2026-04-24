import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../data/analytics.dart';
import '../features/library/library_data.dart';

/// Placeholder marketing URL. Replaced at release time with the real App
/// Store / Play Store listing; keeping it in one place means a single edit
/// when the live links land.
const _serenityUrl = 'https://serenity.app';

/// Open the system share sheet with a session's title + tagline and our
/// marketing URL. On iOS/Android this anchors to the widget's bounds so the
/// popover points at the tapped control (matters on iPad).
Future<void> shareSession(
  BuildContext context,
  LibrarySession session, {
  WidgetRef? ref,
}) {
  final box = context.findRenderObject() as RenderBox?;
  ref?.read(analyticsProvider).track(
        AnalyticsEvents.sessionShared,
        {'sessionId': session.id},
      );
  final origin = box != null
      ? box.localToGlobal(Offset.zero) & box.size
      : null;
  final t = session.localized(Localizations.localeOf(context));
  final message =
      '${t.title} — ${t.tagline}\n\nListening on Serenity · $_serenityUrl';
  return SharePlus.instance
      .share(ShareParams(
        text: message,
        subject: t.title,
        sharePositionOrigin: origin,
      ))
      .then((_) {});
}
