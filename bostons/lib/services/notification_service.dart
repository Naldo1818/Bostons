import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();

    await androidImplementation?.requestExactAlarmsPermission();
  }

  static Future<void> scheduleCallOutReminder({
    required int id,
    required String customerName,
    required String address,
    required DateTime callOutTime,
  }) async {
    final reminderTime = callOutTime.subtract(
      const Duration(minutes: 30),
    );

    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

    await _notifications.zonedSchedule(
      id,
      'Bostons Call Out',
      '$customerName\'s call-out is in 30 minutes.\n$address',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'call_out_reminders',
          'Call Out Reminders',
          channelDescription: 'Notifications for upcoming Bostons call-outs.',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
        ),
      ),
      payload: 'call_out',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelCallOutReminder(int id) async {
    await _notifications.cancel(id);
  }
}
