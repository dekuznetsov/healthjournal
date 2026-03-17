import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'settings_service.dart';
import 'database_helper.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final SettingsService _settingsService = SettingsService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

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

    final enabled = await _settingsService.getNotificationsEnabled();
    if (!enabled) {
      debugPrint('Notifications are disabled in settings.');
      return;
    }

    // Check if data for today already exists
    final records = await _dbHelper.getRecords();
    final today = DateTime.now();
    
    bool hasMorningData = records.any((r) => 
      r.timestamp.year == today.year && 
      r.timestamp.month == today.month && 
      r.timestamp.day == today.day && 
      r.period == 'morning'
    );
    
    bool hasEveningData = records.any((r) => 
      r.timestamp.year == today.year && 
      r.timestamp.month == today.month && 
      r.timestamp.day == today.day && 
      r.period == 'evening'
    );

    final morningTime = await _settingsService.getMorningTime();
    final eveningTime = await _settingsService.getEveningTime();

    // Schedule 6 reminders for morning if no data
    if (!hasMorningData) {
      for (int i = 0; i < 6; i++) {
        final totalMinutes = morningTime.hour * 60 + morningTime.minute + (i * 10);
        final hour = (totalMinutes ~/ 60) % 24;
        final minute = totalMinutes % 60;
        
        await _scheduleNotification(
          id: i,
          title: 'Ранкове вимірювання',
          body: 'Пора поміряти тиск та цукор (${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')})',
          hour: hour,
          minute: minute,
        );
      }
    }

    // Schedule 6 reminders for evening if no data
    if (!hasEveningData) {
      for (int i = 0; i < 6; i++) {
        final totalMinutes = eveningTime.hour * 60 + eveningTime.minute + (i * 10);
        final hour = (totalMinutes ~/ 60) % 24;
        final minute = totalMinutes % 60;

        await _scheduleNotification(
          id: 10 + i,
          title: 'Вечірнє вимірювання',
          body: 'Пора поміряти тиск та цукор (${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')})',
          hour: hour,
          minute: minute,
        );
      }
    }
    
    debugPrint('Daily reminders scheduled (enabled: $enabled, morning: ${!hasMorningData}, evening: ${!hasEveningData})');
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
          channelDescription: 'Нагадування про необхідність вимірювання тиску та цукур',
          importance: Importance.max,
          priority: Priority.high,
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
