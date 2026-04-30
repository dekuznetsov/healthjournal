import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyper_journal/models/health_record.dart';
import 'package:hyper_journal/utils/notification_utils.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Task 8.1 — Unit tests for buildNotificationTimes
  // Requirements: 4.2
  // ---------------------------------------------------------------------------
  group('buildNotificationTimes', () {
    test('morning start 08:00 with baseId 0 → 6 times at 10-min intervals, IDs 0..5', () {
      final result = buildNotificationTimes(const TimeOfDay(hour: 8, minute: 0), 0);

      expect(result.length, 6);

      final expectedTimes = [
        (hour: 8, minute: 0),
        (hour: 8, minute: 10),
        (hour: 8, minute: 20),
        (hour: 8, minute: 30),
        (hour: 8, minute: 40),
        (hour: 8, minute: 50),
      ];

      for (int i = 0; i < 6; i++) {
        expect(result[i].hour, expectedTimes[i].hour,
            reason: 'entry $i: expected hour ${expectedTimes[i].hour}');
        expect(result[i].minute, expectedTimes[i].minute,
            reason: 'entry $i: expected minute ${expectedTimes[i].minute}');
        expect(result[i].id, i, reason: 'entry $i: expected id $i');
      }
    });

    test('evening start 20:00 with baseId 10 → 6 times at 10-min intervals, IDs 10..15', () {
      final result = buildNotificationTimes(const TimeOfDay(hour: 20, minute: 0), 10);

      expect(result.length, 6);

      final expectedTimes = [
        (hour: 20, minute: 0),
        (hour: 20, minute: 10),
        (hour: 20, minute: 20),
        (hour: 20, minute: 30),
        (hour: 20, minute: 40),
        (hour: 20, minute: 50),
      ];

      for (int i = 0; i < 6; i++) {
        expect(result[i].hour, expectedTimes[i].hour,
            reason: 'entry $i: expected hour ${expectedTimes[i].hour}');
        expect(result[i].minute, expectedTimes[i].minute,
            reason: 'entry $i: expected minute ${expectedTimes[i].minute}');
        expect(result[i].id, 10 + i, reason: 'entry $i: expected id ${10 + i}');
      }
    });

    test('midnight wrap: start 23:55 with baseId 0 → wraps past midnight correctly', () {
      final result = buildNotificationTimes(const TimeOfDay(hour: 23, minute: 55), 0);

      expect(result.length, 6);

      // 23:55 + 0*10 = 23:55
      // 23:55 + 1*10 = 24:05 → 00:05
      // 23:55 + 2*10 = 24:15 → 00:15
      // 23:55 + 3*10 = 24:25 → 00:25
      // 23:55 + 4*10 = 24:35 → 00:35
      // 23:55 + 5*10 = 24:45 → 00:45
      final expectedTimes = [
        (hour: 23, minute: 55),
        (hour: 0, minute: 5),
        (hour: 0, minute: 15),
        (hour: 0, minute: 25),
        (hour: 0, minute: 35),
        (hour: 0, minute: 45),
      ];

      for (int i = 0; i < 6; i++) {
        expect(result[i].hour, expectedTimes[i].hour,
            reason: 'entry $i: expected hour ${expectedTimes[i].hour}');
        expect(result[i].minute, expectedTimes[i].minute,
            reason: 'entry $i: expected minute ${expectedTimes[i].minute}');
        expect(result[i].id, i, reason: 'entry $i: expected id $i');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Task 8.2 — Property test for 6-notification scheduling (Property 8)
  // Feature: hyper-journal, Property 8: 6 notifications at 10-minute intervals
  // Validates: Requirements 4.2
  // ---------------------------------------------------------------------------
  group('Property 8: 6 notifications at 10-minute intervals', () {
    test('for 100 random TimeOfDay values, buildNotificationTimes returns exactly 6 entries at correct times and IDs', () {
      // Feature: hyper-journal, Property 8: 6 notifications at 10-minute intervals
      final random = Random(42);

      for (int trial = 0; trial < 100; trial++) {
        final hour = random.nextInt(24);
        final minute = random.nextInt(60);
        final baseId = random.nextBool() ? 0 : 10; // morning or evening base

        final start = TimeOfDay(hour: hour, minute: minute);
        final result = buildNotificationTimes(start, baseId);

        // Must return exactly 6 entries
        expect(result.length, 6,
            reason: 'trial $trial: expected 6 entries for start=$hour:$minute baseId=$baseId');

        for (int i = 0; i < 6; i++) {
          // Compute expected time: startTime + i * 10 minutes (mod 24h)
          final totalMinutes = hour * 60 + minute + (i * 10);
          final expectedHour = (totalMinutes ~/ 60) % 24;
          final expectedMinute = totalMinutes % 60;
          final expectedId = baseId + i;

          expect(result[i].hour, expectedHour,
              reason: 'trial $trial, entry $i: expected hour $expectedHour, got ${result[i].hour}');
          expect(result[i].minute, expectedMinute,
              reason: 'trial $trial, entry $i: expected minute $expectedMinute, got ${result[i].minute}');
          expect(result[i].id, expectedId,
              reason: 'trial $trial, entry $i: expected id $expectedId, got ${result[i].id}');
        }
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Task 10.1 — Unit tests for shouldSkipPeriod
  // Requirements: 4.3, 4.4
  // ---------------------------------------------------------------------------
  group('shouldSkipPeriod', () {
    final today = DateTime(2024, 6, 15, 10, 0);

    HealthRecord makeRecord({
      required String period,
      required DateTime timestamp,
    }) {
      return HealthRecord(
        systolic: 120,
        diastolic: 80,
        pulse: 70,
        timestamp: timestamp,
        period: period,
      );
    }

    test('list with morning record for today → shouldSkipPeriod morning == true', () {
      final records = [
        makeRecord(period: 'morning', timestamp: DateTime(2024, 6, 15, 8, 0)),
      ];
      expect(shouldSkipPeriod(records, 'morning', today), isTrue);
    });

    test('list with evening record for today → shouldSkipPeriod evening == true', () {
      final records = [
        makeRecord(period: 'evening', timestamp: DateTime(2024, 6, 15, 20, 0)),
      ];
      expect(shouldSkipPeriod(records, 'evening', today), isTrue);
    });

    test('list with morning record for yesterday → shouldSkipPeriod morning == false', () {
      final records = [
        makeRecord(period: 'morning', timestamp: DateTime(2024, 6, 14, 8, 0)),
      ];
      expect(shouldSkipPeriod(records, 'morning', today), isFalse);
    });

    test('empty list → morning returns false', () {
      expect(shouldSkipPeriod([], 'morning', today), isFalse);
    });

    test('empty list → evening returns false', () {
      expect(shouldSkipPeriod([], 'evening', today), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // Task 10.2 — Property test for notification skip logic (Property 9)
  // Feature: hyper-journal, Property 9: Skip notifications when today's record exists
  // Validates: Requirements 4.3, 4.4
  // ---------------------------------------------------------------------------
  group('Property 9: Skip notifications when today\'s record exists', () {
    // Feature: hyper-journal, Property 9: Skip notifications when today's record exists
    final random = Random(99);
    final today = DateTime(2024, 6, 15, 10, 0);

    HealthRecord makeRecord({required String period, required DateTime timestamp}) {
      return HealthRecord(
        systolic: 110 + random.nextInt(40),
        diastolic: 70 + random.nextInt(30),
        pulse: 60 + random.nextInt(40),
        timestamp: timestamp,
        period: period,
      );
    }

    /// Generates a random DateTime that is on [today] (same year/month/day).
    DateTime randomTimeToday() {
      return DateTime(today.year, today.month, today.day,
          random.nextInt(24), random.nextInt(60));
    }

    /// Generates a random DateTime that is NOT on [today] (1–30 days before).
    DateTime randomTimeNotToday() {
      final daysBack = 1 + random.nextInt(30);
      return today.subtract(Duration(days: daysBack));
    }

    /// Generates a list of 0–4 random records that do NOT include [period] for today.
    List<HealthRecord> randomRecordsWithoutPeriodToday(String period) {
      final count = random.nextInt(5); // 0..4 records
      return List.generate(count, (_) {
        // Either a different period today, or the same period on a different day
        final useOtherPeriodToday = random.nextBool();
        if (useOtherPeriodToday) {
          final otherPeriod = period == 'morning' ? 'evening' : 'morning';
          return makeRecord(period: otherPeriod, timestamp: randomTimeToday());
        } else {
          return makeRecord(period: period, timestamp: randomTimeNotToday());
        }
      });
    }

    test(
        'for 100 random record sets with at least one morning record for today: '
        'shouldSkipPeriod morning == true', () {
      for (int trial = 0; trial < 100; trial++) {
        // Build a base list without a morning record for today
        final base = randomRecordsWithoutPeriodToday('morning');
        // Add at least one morning record for today
        final todayRecord = makeRecord(period: 'morning', timestamp: randomTimeToday());
        final records = [...base, todayRecord]..shuffle(random);

        expect(
          shouldSkipPeriod(records, 'morning', today),
          isTrue,
          reason: 'trial $trial: expected true when morning record for today exists',
        );
      }
    });

    test(
        'for 100 random record sets with no morning record for today: '
        'shouldSkipPeriod morning == false', () {
      for (int trial = 0; trial < 100; trial++) {
        final records = randomRecordsWithoutPeriodToday('morning');

        expect(
          shouldSkipPeriod(records, 'morning', today),
          isFalse,
          reason: 'trial $trial: expected false when no morning record for today',
        );
      }
    });

    test(
        'for 100 random record sets with at least one evening record for today: '
        'shouldSkipPeriod evening == true', () {
      for (int trial = 0; trial < 100; trial++) {
        final base = randomRecordsWithoutPeriodToday('evening');
        final todayRecord = makeRecord(period: 'evening', timestamp: randomTimeToday());
        final records = [...base, todayRecord]..shuffle(random);

        expect(
          shouldSkipPeriod(records, 'evening', today),
          isTrue,
          reason: 'trial $trial: expected true when evening record for today exists',
        );
      }
    });

    test(
        'for 100 random record sets with no evening record for today: '
        'shouldSkipPeriod evening == false', () {
      for (int trial = 0; trial < 100; trial++) {
        final records = randomRecordsWithoutPeriodToday('evening');

        expect(
          shouldSkipPeriod(records, 'evening', today),
          isFalse,
          reason: 'trial $trial: expected false when no evening record for today',
        );
      }
    });
  });
}
