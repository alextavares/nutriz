import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const init = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(init);
    _initialized = true;
  }

  static Future<void> requestPermissionsIfNeeded() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // No runtime permission required on modern Android for local notifications
      return;
    }
    await _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> showHydrationReminder({required String body}) async {
    await initialize();
    const androidDetails = AndroidNotificationDetails(
      'hydration_channel',
      'Hidratação',
      channelDescription: 'Lembretes de beber água',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _plugin.show(1001, 'Hora de beber água', body, details);
  }
}


