import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'settings_service.dart';
import 'database_helper.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final SettingsService _settingsService = SettingsService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _initialized = false;

  static bool get isSupported =>
      !kIsWeb &&
      (Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux);

  Future<void> init() async {
    if (!isSupported) return;

    await _configureLocalTimeZone();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('scheduled_notifications');

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // v21 uses named parameter 'settings:'
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: (r) =>
          debugPrint('Notification tapped: ${r.payload}'),
    );

    _initialized = true;
    await scheduleDailyReminders();
  }

  Future<void> scheduleDailyReminders({
    String morningTitle = 'Morning Measurement',
    String morningBody = 'Time to measure blood pressure and sugar',
    String eveningTitle = 'Evening Measurement',
    String eveningBody = 'Time to measure blood pressure and sugar',
    String channelName = 'Health Reminders',
    String channelDesc = 'Reminders to measure blood pressure and blood sugar',
  }) async {
    if (!isSupported || !_initialized) return;

    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('cancelAll error: $e');
    }

    final enabled = await _settingsService.getNotificationsEnabled();
    if (!enabled) return;

    final records = await _dbHelper.getRecords();
    final today = DateTime.now();

    final hasMorning = records.any((r) =>
        r.timestamp.year == today.year &&
        r.timestamp.month == today.month &&
        r.timestamp.day == today.day &&
        r.period == 'morning');

    final hasEvening = records.any((r) =>
        r.timestamp.year == today.year &&
        r.timestamp.month == today.month &&
        r.timestamp.day == today.day &&
        r.period == 'evening');

    final morningTime = await _settingsService.getMorningTime();
    final eveningTime = await _settingsService.getEveningTime();

    if (!hasMorning) {
      for (int i = 0; i < 6; i++) {
        final total = morningTime.hour * 60 + morningTime.minute + (i * 10);
        await _schedule(
          id: i,
          title: morningTitle,
          body: morningBody,
          hour: (total ~/ 60) % 24,
          minute: total % 60,
          channelName: channelName,
          channelDesc: channelDesc,
        );
      }
    }

    if (!hasEvening) {
      for (int i = 0; i < 6; i++) {
        final total = eveningTime.hour * 60 + eveningTime.minute + (i * 10);
        await _schedule(
          id: 10 + i,
          title: eveningTitle,
          body: eveningBody,
          hour: (total ~/ 60) % 24,
          minute: total % 60,
          channelName: channelName,
          channelDesc: channelDesc,
        );
      }
    }

    debugPrint('Reminders scheduled (morning: ${!hasMorning}, evening: ${!hasEvening})');
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String channelName,
    required String channelDesc,
  }) async {
    final details = Platform.isAndroid
        ? NotificationDetails(
            android: AndroidNotificationDetails(
              'health_reminders',
              channelName,
              channelDescription: channelDesc,
              importance: Importance.max,
              priority: Priority.high,
            ),
          )
        : const NotificationDetails(
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
            macOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          );

    // v21 uses named parameters for zonedSchedule
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextTime(hour, minute),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (t.isBefore(now)) t = t.add(const Duration(days: 1));
    return t;
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));
  }
}
