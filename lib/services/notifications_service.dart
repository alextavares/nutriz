import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static bool _tzInitialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const init = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(init);
    _initialized = true;
  }

  static Future<void> _ensureTimezone() async {
    if (!_tzInitialized) {
      try {
        tzdata.initializeTimeZones();
      } catch (_) {}
      _tzInitialized = true;
    }
    // Without native plugin, keep default tz.local. We schedule by relative deltas.
  }

  static Future<String> getLocalTimezoneName() async {
    // Best-effort: use Dart's timeZoneName
    return DateTime.now().timeZoneName;
  }

  static Future<void> requestPermissionsIfNeeded() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // No runtime permission required on modern Android for local notifications
      return;
    }
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> showHydrationReminder({
    required String title,
    required String body,
    String channelName = 'Hydration',
    String channelDescription = 'Drink water reminders',
  }) async {
    await initialize();
    final androidDetails = AndroidNotificationDetails(
      'hydration_channel',
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails();
    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _plugin.show(1001, title, body, details);
  }

  // Schedule a notification for fasting end
  static Future<void> scheduleFastingEnd({
    required DateTime endAt,
    required String method,
    required String title,
    required String body,
    String channelName = 'Fasting',
    String channelDescription = 'Intermittent fasting notifications',
  }) async {
    await initialize();
    await _ensureTimezone();
    final now = DateTime.now();
    final diff = endAt.difference(now);
    if (diff.inSeconds <= 0) {
      await _showFastingEndNow(title: title, body: body);
      return;
    }
    final scheduleTime = tz.TZDateTime.now(tz.local).add(diff);
    final androidDetails = AndroidNotificationDetails(
      'fasting_channel',
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails();
    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    try {
      await _plugin.zonedSchedule(
        2001,
        title,
        body,
        scheduleTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    } catch (err, stack) {
      debugPrint('NotificationsService.scheduleFastingEnd error: $err');
      debugPrintStack(stackTrace: stack);
    }
  }

  static Future<void> cancelFastingEnd() async {
    await initialize();
    await _plugin.cancel(2001);
  }

  static Future<void> _showFastingEndNow({
    required String title,
    required String body,
    String channelName = 'Fasting',
    String channelDescription = 'Intermittent fasting notifications',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'fasting_channel',
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails();
    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _plugin.show(2001, title, body, details);
  }

  // Daily reminders at specific local times
  static Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String channelName = 'Fasting',
    String channelDescription = 'Intermittent fasting notifications',
  }) async {
    await initialize();
    await _ensureTimezone();
    // Compute relative delta to next occurrence in local time, then add to tz.now
    final nowLocal = DateTime.now();
    var target =
        DateTime(nowLocal.year, nowLocal.month, nowLocal.day, hour, minute);
    if (target.isBefore(nowLocal)) target = target.add(const Duration(days: 1));
    final diff = target.difference(nowLocal);
    final nowTz = tz.TZDateTime.now(tz.local);
    final scheduled = nowTz.add(diff);
    final androidDetails = AndroidNotificationDetails(
      'fasting_channel',
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails();
    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (err, stack) {
      debugPrint('NotificationsService.scheduleDailyReminder failed for id '
          '$id: $err');
      debugPrintStack(stackTrace: stack);
    }
  }

  static Future<void> cancelDailyReminder(int id) async {
    await initialize();
    await _plugin.cancel(id);
  }

  static Future<void> scheduleDailyFastingReminders({
    required int startEatingHour,
    required int startEatingMinute,
    required int stopEatingHour,
    required int stopEatingMinute,
    required String openTitle,
    required String openBody,
    required String startTitle,
    required String startBody,
    String channelName = 'Fasting',
    String channelDescription = 'Intermittent fasting notifications',
  }) async {
    await _ensureTimezone();
    await scheduleDailyReminder(
      id: 2002,
      title: openTitle,
      body: openBody,
      hour: startEatingHour,
      minute: startEatingMinute,
      channelName: channelName,
      channelDescription: channelDescription,
    );
    await scheduleDailyReminder(
      id: 2003,
      title: startTitle,
      body: startBody,
      hour: stopEatingHour,
      minute: stopEatingMinute,
      channelName: channelName,
      channelDescription: channelDescription,
    );
  }

  static Future<void> cancelDailyFastingReminders() async {
    await cancelDailyReminder(2002);
    await cancelDailyReminder(2003);
  }

  // Mute management (store until ISO)
  static const String _kFastingMuteUntilIso = 'fasting_mute_until_iso_v1';

  static Future<void> setFastingMuteUntil(DateTime? until) async {
    final prefs = await SharedPreferences.getInstance();
    if (until == null) {
      await prefs.remove(_kFastingMuteUntilIso);
    } else {
      await prefs.setString(_kFastingMuteUntilIso, until.toIso8601String());
    }
  }

  static Future<DateTime?> getFastingMuteUntil() async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString(_kFastingMuteUntilIso);
    if (iso == null || iso.isEmpty) return null;
    try {
      return DateTime.parse(iso);
    } catch (_) {
      return null;
    }
  }
}
