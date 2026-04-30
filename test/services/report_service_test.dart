import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyper_journal/models/health_record.dart';
import 'package:hyper_journal/services/report_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates a [HealthRecord] with the given [timestamp] and optional [sugar].
HealthRecord _record({
  required DateTime timestamp,
  int systolic = 120,
  int diastolic = 80,
  int pulse = 70,
  double? sugar,
  String period = 'morning',
}) {
  return HealthRecord(
    systolic: systolic,
    diastolic: diastolic,
    pulse: pulse,
    sugar: sugar,
    timestamp: timestamp,
    period: period,
  );
}

/// Generates a random [HealthRecord] using [rng].
HealthRecord _randomRecord(Random rng) {
  final year = 2020 + rng.nextInt(5);
  final month = 1 + rng.nextInt(12);
  final day = 1 + rng.nextInt(28); // safe for all months
  final hour = rng.nextInt(24);
  final minute = rng.nextInt(60);
  final second = rng.nextInt(60);
  final timestamp = DateTime(year, month, day, hour, minute, second);

  final systolic = 70 + rng.nextInt(181); // 70–250
  final diastolic = 40 + rng.nextInt(111); // 40–150
  final pulse = 30 + rng.nextInt(171); // 30–200

  // 50 % chance of null sugar
  final double? sugar = rng.nextBool() ? null : 1.0 + rng.nextDouble() * 29.0;

  final period = rng.nextBool() ? 'morning' : 'evening';

  return HealthRecord(
    systolic: systolic,
    diastolic: diastolic,
    pulse: pulse,
    sugar: sugar,
    timestamp: timestamp,
    period: period,
  );
}

// ---------------------------------------------------------------------------
// Task 12.1 — Unit tests for formatRecordRow
// ---------------------------------------------------------------------------

void main() {
  group('formatRecordRow — unit tests', () {
    // Validates: Requirements 5.4, 5.5

    test('date is formatted as dd.MM.yyyy', () {
      final r = _record(timestamp: DateTime(2024, 3, 5, 8, 30));
      final row = formatRecordRow(r);
      expect(row[0], equals('05.03.2024'));
    });

    test('time is formatted as HH:mm', () {
      final r = _record(timestamp: DateTime(2024, 3, 5, 8, 7));
      final row = formatRecordRow(r);
      expect(row[1], equals('08:07'));
    });

    test('pressure is formatted as SYS/DIA', () {
      final r = _record(
        timestamp: DateTime(2024, 1, 1, 8, 0),
        systolic: 120,
        diastolic: 80,
      );
      final row = formatRecordRow(r);
      expect(row[3], equals('120/80'));
    });

    test('sugar == null → "-" in sugar column', () {
      final r = _record(timestamp: DateTime(2024, 1, 1, 8, 0), sugar: null);
      final row = formatRecordRow(r);
      expect(row[5], equals('-'));
    });

    test('sugar == 5.5 → "5.5" in sugar column', () {
      final r = _record(timestamp: DateTime(2024, 1, 1, 8, 0), sugar: 5.5);
      final row = formatRecordRow(r);
      expect(row[5], equals('5.5'));
    });

    test('row has exactly 6 columns', () {
      final r = _record(timestamp: DateTime(2024, 6, 15, 20, 0));
      expect(formatRecordRow(r).length, equals(6));
    });

    test('pulse is formatted as integer string', () {
      final r = _record(timestamp: DateTime(2024, 1, 1, 8, 0), pulse: 72);
      final row = formatRecordRow(r);
      expect(row[4], equals('72'));
    });
  });

  // ---------------------------------------------------------------------------
  // Task 12.2 — Property 12: PDF report field formatting
  // ---------------------------------------------------------------------------

  // Feature: hyper-journal, Property 12: PDF report field formatting
  test('Property 12: PDF report field formatting — 100 random records', () {
    // Validates: Requirements 5.4, 5.5
    final rng = Random(42);
    final datePattern = RegExp(r'^\d{2}\.\d{2}\.\d{4}$');
    final timePattern = RegExp(r'^\d{2}:\d{2}$');
    final pressurePattern = RegExp(r'^\d+/\d+$');

    for (int i = 0; i < 100; i++) {
      final r = _randomRecord(rng);
      final row = formatRecordRow(r);

      // [0] date matches dd.MM.yyyy
      expect(
        row[0],
        matches(datePattern),
        reason: 'date "${row[0]}" does not match dd.MM.yyyy for record $i',
      );

      // [1] time matches HH:mm
      expect(
        row[1],
        matches(timePattern),
        reason: 'time "${row[1]}" does not match HH:mm for record $i',
      );

      // [3] pressure matches SYS/DIA
      expect(
        row[3],
        matches(pressurePattern),
        reason: 'pressure "${row[3]}" does not match SYS/DIA for record $i',
      );

      // [5] sugar == '-' when sugar is null
      if (r.sugar == null) {
        expect(
          row[5],
          equals('-'),
          reason: 'sugar column should be "-" when sugar is null (record $i)',
        );
      }
    }
  });

  // ---------------------------------------------------------------------------
  // Task 12.3 — Unit tests for filterAndSortForReport
  // ---------------------------------------------------------------------------

  group('filterAndSortForReport — unit tests', () {
    // Validates: Requirements 5.1, 5.2

    late DateTime now;

    setUp(() {
      now = DateTime(2024, 6, 15, 12, 0);
    });

    test('records older than 30 days are excluded', () {
      final old = _record(
        timestamp: now.subtract(const Duration(days: 31)),
      );
      final result = filterAndSortForReport([old], now);
      expect(result, isEmpty);
    });

    test('records exactly 30 days ago are excluded (strictly after)', () {
      // The filter uses isAfter(thirtyDaysAgo), so exactly 30 days ago is excluded.
      final boundary = now.subtract(const Duration(days: 30));
      final r = _record(timestamp: boundary);
      final result = filterAndSortForReport([r], now);
      expect(result, isEmpty);
    });

    test('records within 30 days are included', () {
      final recent = _record(
        timestamp: now.subtract(const Duration(days: 29)),
      );
      final result = filterAndSortForReport([recent], now);
      expect(result.length, equals(1));
    });

    test('records from today are included', () {
      final today = _record(timestamp: now);
      final result = filterAndSortForReport([today], now);
      expect(result.length, equals(1));
    });

    test('resulting list is sorted DESC by timestamp', () {
      final r1 = _record(timestamp: now.subtract(const Duration(days: 1)));
      final r2 = _record(timestamp: now.subtract(const Duration(days: 5)));
      final r3 = _record(timestamp: now.subtract(const Duration(days: 10)));

      // Insert in non-sorted order
      final result = filterAndSortForReport([r2, r3, r1], now);

      expect(result.length, equals(3));
      expect(result[0].timestamp, equals(r1.timestamp)); // newest first
      expect(result[1].timestamp, equals(r2.timestamp));
      expect(result[2].timestamp, equals(r3.timestamp)); // oldest last
    });

    test('mix of old and recent records — only recent returned, sorted DESC', () {
      final old = _record(timestamp: now.subtract(const Duration(days: 45)));
      final r1 = _record(timestamp: now.subtract(const Duration(days: 2)));
      final r2 = _record(timestamp: now.subtract(const Duration(days: 15)));

      final result = filterAndSortForReport([old, r2, r1], now);

      expect(result.length, equals(2));
      expect(result[0].timestamp, equals(r1.timestamp));
      expect(result[1].timestamp, equals(r2.timestamp));
    });

    test('empty input returns empty list', () {
      final result = filterAndSortForReport([], now);
      expect(result, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // Task 12.4 — Property 11: PDF report sorted DESC
  // ---------------------------------------------------------------------------

  // Feature: hyper-journal, Property 11: PDF report sorted DESC
  test('Property 11: PDF report sorted DESC — 100 random record sets', () {
    // Validates: Requirements 5.2
    final rng = Random(99);
    final now = DateTime(2024, 6, 15, 12, 0);

    for (int trial = 0; trial < 100; trial++) {
      // Generate between 0 and 20 records, each within the last 30 days
      final count = rng.nextInt(21);
      final records = List.generate(count, (_) {
        // Timestamps within the last 29 days (strictly after 30-day cutoff)
        final daysAgo = rng.nextInt(29); // 0..28
        final hoursAgo = rng.nextInt(24);
        final minutesAgo = rng.nextInt(60);
        final ts = now.subtract(
          Duration(days: daysAgo, hours: hoursAgo, minutes: minutesAgo),
        );
        return _record(timestamp: ts);
      });

      final result = filterAndSortForReport(records, now);

      // Every adjacent pair must satisfy result[i].timestamp >= result[i+1].timestamp
      for (int i = 0; i < result.length - 1; i++) {
        expect(
          result[i].timestamp.compareTo(result[i + 1].timestamp),
          greaterThanOrEqualTo(0),
          reason:
              'Trial $trial: result[$i].timestamp (${result[i].timestamp}) '
              'should be >= result[${i + 1}].timestamp (${result[i + 1].timestamp})',
        );
      }
    }
  });
}
