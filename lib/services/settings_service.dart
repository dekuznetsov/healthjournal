import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyMorningHour = 'morning_hour';
  static const String _keyMorningMinute = 'morning_minute';
  static const String _keyEveningHour = 'evening_hour';
  static const String _keyEveningMinute = 'evening_minute';

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, value);
  }

  Future<TimeOfDay> getMorningTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_keyMorningHour) ?? 8;
    final minute = prefs.getInt(_keyMorningMinute) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> setMorningTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMorningHour, time.hour);
    await prefs.setInt(_keyMorningMinute, time.minute);
  }

  Future<TimeOfDay> getEveningTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_keyEveningHour) ?? 20;
    final minute = prefs.getInt(_keyEveningMinute) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> setEveningTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyEveningHour, time.hour);
    await prefs.setInt(_keyEveningMinute, time.minute);
  }
}
