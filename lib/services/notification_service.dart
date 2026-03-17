import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
      },
    );
    
    // Schedule reminders immediately upon initialization
    await scheduleDailyReminders();
  }

  Future<void> scheduleDailyReminders() async {
    // Clear all existing notifications to avoid duplicates
    await _notificationsPlugin.cancelAll();

    // Schedule 6 reminders for morning (08:00 - 08:50)
    for (int i = 0; i < 6; i++) {
      final minute = i * 10;
      await _scheduleNotification(
        id: i,
        title: 'Ранкове вимірювання',
        body: 'Пора поміряти тиск та цукор (08:${minute.toString().padLeft(2, '0')})',
        hour: 8,
        minute: minute,
      );
    }

    // Schedule 6 reminders for evening (20:00 - 20:50)
    for (int i = 0; i < 6; i++) {
      final minute = i * 10;
      await _scheduleNotification(
        id: 10 + i,
        title: 'Вечірнє вимірювання',
        body: 'Пора поміряти тиск та цукор (20:${minute.toString().padLeft(2, '0')})',
        hour: 20,
        minute: minute,
      );
    }
    
    debugPrint('Daily reminders scheduled (8:00 and 20:00 with 10m intervals)');
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'health_reminders',
          'Нагадування про здоров\'я',
          channelDescription: 'Нагадування про необхідність вимірювання тиску та цукру',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('notification_sound'), // Custom sound if exists
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat every day at this time
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
