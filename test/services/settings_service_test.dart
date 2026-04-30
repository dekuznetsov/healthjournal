// Feature: hyper-journal
// Tests for SettingsService defaults, persistence, and Property 10 round-trip.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hyper_journal/services/settings_service.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Task 9.1 — Unit tests for SettingsService defaults and persistence
  // ---------------------------------------------------------------------------
  group('SettingsService defaults', () {
    setUp(() async {
      // Reset SharedPreferences to an empty state before each test so that
      // the singleton reads fresh (default) values.
      SharedPreferences.setMockInitialValues({});
    });

    test('getNotificationsEnabled() returns true by default', () async {
      final service = SettingsService();
      final enabled = await service.getNotificationsEnabled();
      expect(enabled, isTrue);
    });

    test('getMorningTime() returns TimeOfDay(8, 0) by default', () async {
      final service = SettingsService();
      final time = await service.getMorningTime();
      expect(time, equals(const TimeOfDay(hour: 8, minute: 0)));
    });

    test('getEveningTime() returns TimeOfDay(20, 0) by default', () async {
      final service = SettingsService();
      final time = await service.getEveningTime();
      expect(time, equals(const TimeOfDay(hour: 20, minute: 0)));
    });

    test('setNotificationsEnabled persists the value', () async {
      final service = SettingsService();
      await service.setNotificationsEnabled(false);
      final enabled = await service.getNotificationsEnabled();
      expect(enabled, isFalse);
    });

    test('setMorningTime persists the value', () async {
      final service = SettingsService();
      const newTime = TimeOfDay(hour: 7, minute: 30);
      await service.setMorningTime(newTime);
      final time = await service.getMorningTime();
      expect(time, equals(newTime));
    });

    test('setEveningTime persists the value', () async {
      final service = SettingsService();
      const newTime = TimeOfDay(hour: 21, minute: 15);
      await service.setEveningTime(newTime);
      final time = await service.getEveningTime();
      expect(time, equals(newTime));
    });
  });

  // ---------------------------------------------------------------------------
  // Task 9.2 — Property 10: SettingsService round-trip save/read
  // ---------------------------------------------------------------------------
  // Feature: hyper-journal, Property 10: SettingsService round-trip
  // Validates: Requirements 4.7, 4.8, 4.9
  group('Property 10: SettingsService round-trip save/read', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test(
        'setMorningTime / getMorningTime round-trip holds for 100 random TimeOfDay values',
        () async {
      final service = SettingsService();
      final rng = Random(42);

      for (int i = 0; i < 100; i++) {
        final hour = rng.nextInt(24); // [0, 23]
        final minute = rng.nextInt(60); // [0, 59]
        final t = TimeOfDay(hour: hour, minute: minute);

        await service.setMorningTime(t);
        final result = await service.getMorningTime();

        expect(result, equals(t),
            reason:
                'getMorningTime() should return $t after setMorningTime($t) '
                'at iteration $i');
      }
    });

    test(
        'setEveningTime / getEveningTime round-trip holds for 100 random TimeOfDay values',
        () async {
      final service = SettingsService();
      final rng = Random(7);

      for (int i = 0; i < 100; i++) {
        final hour = rng.nextInt(24); // [0, 23]
        final minute = rng.nextInt(60); // [0, 59]
        final t = TimeOfDay(hour: hour, minute: minute);

        await service.setEveningTime(t);
        final result = await service.getEveningTime();

        expect(result, equals(t),
            reason:
                'getEveningTime() should return $t after setEveningTime($t) '
                'at iteration $i');
      }
    });

    test(
        'setNotificationsEnabled / getNotificationsEnabled round-trip holds for 100 random booleans',
        () async {
      final service = SettingsService();
      final rng = Random(99);

      for (int i = 0; i < 100; i++) {
        final b = rng.nextBool();

        await service.setNotificationsEnabled(b);
        final result = await service.getNotificationsEnabled();

        expect(result, equals(b),
            reason:
                'getNotificationsEnabled() should return $b after '
                'setNotificationsEnabled($b) at iteration $i');
      }
    });
  });
}
