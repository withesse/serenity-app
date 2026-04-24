import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper around `flutter_local_notifications` that handles init,
/// permission prompts, and scheduling the two reminders Serenity uses:
///   - Daily practice reminder (user-configurable hour; default 21:00)
///   - Bedtime reminder (30 min before the user's usual sleep window)
///
/// Reminders are rescheduled whenever the relevant Settings toggle changes
/// — see `SettingsController.setDailyReminder` / `setSleepReminder`.
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _inited = false;

  static const _channelId = 'serenity_reminders';
  static const _channelName = 'Serenity reminders';
  static const _channelDesc = 'Daily practice and bedtime reminders.';

  static const _idDaily = 1001;
  static const _idBedtime = 1002;

  static Future<void> init() async {
    if (_inited) return;
    tz_data.initializeTimeZones();
    // Resolve the device's real IANA timezone name from the platform.
    // Without this step `tz.local` defaults to UTC, so non-UTC users
    // would get their daily/bedtime reminders at the wrong local hour.
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e, st) {
      // Fall back to UTC only when the platform refused to hand over a
      // usable name. Surface the failure through Flutter's error channel
      // so CrashReporter's installed handler still catches it — this
      // module has no Ref to call reportError directly.
      FlutterError.reportError(FlutterErrorDetails(
        exception: e,
        stack: st,
        library: 'serenity/notifications',
        context: ErrorDescription('resolving device timezone'),
      ));
      tz.setLocalLocation(tz.UTC);
    }

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings: initSettings);
    _inited = true;
  }

  /// Request OS permission. Returns true if granted. Safe to call repeatedly —
  /// the OS will only prompt on first call.
  static Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  /// Schedule the daily practice reminder at [time] on the device's local
  /// clock. Replaces any previous daily reminder. If [time] is null the
  /// reminder is cancelled instead.
  static Future<void> setDailyReminder({TimeOfDay? time}) async {
    await _plugin.cancel(id: _idDaily);
    if (time == null) return;
    final details = _details();
    await _plugin.zonedSchedule(
      id: _idDaily,
      title: 'A quiet moment',
      body: 'A short session will help you land softly into the evening.',
      scheduledDate: _nextInstanceOf(time),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule the bedtime reminder at [time]. null = cancel.
  static Future<void> setBedtimeReminder({TimeOfDay? time}) async {
    await _plugin.cancel(id: _idBedtime);
    if (time == null) return;
    final details = _details();
    await _plugin.zonedSchedule(
      id: _idBedtime,
      title: 'Time to unwind',
      body: 'Drifting into Stillness is waiting — let the night begin gently.',
      scheduledDate: _nextInstanceOf(time),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelAll() => _plugin.cancelAll();

  // --- Internals ---

  static NotificationDetails _details() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: DarwinNotificationDetails(),
      );

  static tz.TZDateTime _nextInstanceOf(TimeOfDay t) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      t.hour,
      t.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

/// Simple timezone-agnostic time-of-day for scheduling. Kept separate from
/// Flutter's [material.TimeOfDay] so this module can be used from a non-UI
/// layer without importing material.
@immutable
class TimeOfDay {
  const TimeOfDay({required this.hour, required this.minute});
  final int hour;
  final int minute;
}
