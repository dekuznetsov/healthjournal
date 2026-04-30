// Feature: hyper-journal
// Tests for DatabaseHelper CRUD operations and properties 5, 6, 7.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:hyper_journal/models/health_record.dart';
import 'package:hyper_journal/services/database_helper.dart';

/// Generates a random valid [HealthRecord] using [rng].
HealthRecord _randomRecord(Random rng) {
  final systolic = 70 + rng.nextInt(181); // 70–250
  final diastolic = 40 + rng.nextInt(111); // 40–150
  final pulse = 30 + rng.nextInt(171); // 30–200
  final sugar = 1.0 + rng.nextDouble() * 29.0; // 1.0–30.0
  // Random timestamp within the last year, truncated to seconds
  final now = DateTime.now();
  final offsetSeconds = rng.nextInt(365 * 24 * 3600);
  final ts = now
      .subtract(Duration(seconds: offsetSeconds))
      .toUtc()
      .copyWith(microsecond: 0, millisecond: 0);
  final period = rng.nextBool() ? 'morning' : 'evening';
  return HealthRecord(
    systolic: systolic,
    diastolic: diastolic,
    pulse: pulse,
    sugar: sugar,
    timestamp: ts,
    period: period,
  );
}

void main() {
  // Initialise sqflite FFI once for the entire test run.
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // Force DatabaseHelper to use an in-memory database instead of the
    // on-disk 'health_tracker.db' path.
    DatabaseHelper.databasePathOverride = inMemoryDatabasePath;
  });

  // ---------------------------------------------------------------------------
  // Task 6.1 — Unit tests for CRUD operations
  // ---------------------------------------------------------------------------
  group('DatabaseHelper CRUD', () {
    // Reset the singleton and clear all records before every test.
    setUp(() async {
      DatabaseHelper.resetForTesting();
      await DatabaseHelper().deleteAllRecords();
    });

    test('insertRecord returns a positive integer id', () async {
      final db = DatabaseHelper();
      final record = HealthRecord(
        systolic: 120,
        diastolic: 80,
        pulse: 70,
        sugar: 5.5,
        timestamp: DateTime.utc(2024, 1, 15, 8, 0, 0),
        period: 'morning',
      );
      final id = await db.insertRecord(record);
      expect(id, greaterThan(0));
    });

    test('getRecords returns empty list on fresh database', () async {
      final db = DatabaseHelper();
      // Explicitly clear the database to ensure a clean state.
      await db.deleteAllRecords();
      final records = await db.getRecords();
      expect(records, isEmpty);
    });

    test('deleteAllRecords leaves database empty', () async {
      final db = DatabaseHelper();
      // Insert a couple of records first.
      await db.insertRecord(HealthRecord(
        systolic: 120,
        diastolic: 80,
        pulse: 70,
        timestamp: DateTime.utc(2024, 1, 15, 8, 0, 0),
        period: 'morning',
      ));
      await db.insertRecord(HealthRecord(
        systolic: 130,
        diastolic: 85,
        pulse: 75,
        timestamp: DateTime.utc(2024, 1, 15, 20, 0, 0),
        period: 'evening',
      ));

      await db.deleteAllRecords();
      final records = await db.getRecords();
      expect(records, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // Task 6.2 — Property 5: HealthRecord round-trip save/read
  // ---------------------------------------------------------------------------
  // Feature: hyper-journal, Property 5: HealthRecord round-trip save/read
  // Validates: Requirements 1.15, 8.1, 8.2
  group('Property 5: HealthRecord round-trip save/read', () {
    setUp(() async {
      await DatabaseHelper().deleteAllRecords();
    });

    test('inserted record is retrievable with identical field values', () async {
      final db = DatabaseHelper();
      final rng = Random(42);

      for (int i = 0; i < 100; i++) {
        final original = _randomRecord(rng);
        final id = await db.insertRecord(original);

        final records = await db.getRecords();
        final found = records.where((r) => r.id == id).toList();

        expect(found, hasLength(1),
            reason: 'Record with id=$id should be in getRecords()');

        final r = found.first;
        expect(r.systolic, equals(original.systolic),
            reason: 'systolic mismatch at iteration $i');
        expect(r.diastolic, equals(original.diastolic),
            reason: 'diastolic mismatch at iteration $i');
        expect(r.pulse, equals(original.pulse),
            reason: 'pulse mismatch at iteration $i');
        expect(r.sugar, closeTo(original.sugar!, 1e-9),
            reason: 'sugar mismatch at iteration $i');
        expect(r.period, equals(original.period),
            reason: 'period mismatch at iteration $i');
        // Timestamps are stored as ISO-8601 strings; compare to second precision.
        expect(
          r.timestamp.toUtc().toIso8601String().substring(0, 19),
          equals(original.timestamp.toUtc().toIso8601String().substring(0, 19)),
          reason: 'timestamp mismatch at iteration $i',
        );
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Task 6.3 — Property 6: Records sorted in reverse chronological order
  // ---------------------------------------------------------------------------
  // Feature: hyper-journal, Property 6: Records sorted DESC
  // Validates: Requirements 2.1, 8.6
  group('Property 6: Records sorted DESC', () {
    setUp(() async {
      await DatabaseHelper().deleteAllRecords();
    });

    test('getRecords returns records in reverse chronological order', () async {
      final db = DatabaseHelper();
      final rng = Random(7);

      // Run 10 independent trials, each with a fresh batch of records.
      for (int trial = 0; trial < 10; trial++) {
        await db.deleteAllRecords();

        final count = 10 + rng.nextInt(11); // 10–20 records
        final now = DateTime.now();

        for (int i = 0; i < count; i++) {
          final offsetSeconds = rng.nextInt(365 * 24 * 3600);
          final ts = now
              .subtract(Duration(seconds: offsetSeconds))
              .toUtc()
              .copyWith(microsecond: 0, millisecond: 0);
          await db.insertRecord(HealthRecord(
            systolic: 120,
            diastolic: 80,
            pulse: 70,
            timestamp: ts,
            period: rng.nextBool() ? 'morning' : 'evening',
          ));
        }

        final records = await db.getRecords();
        expect(records.length, equals(count));

        for (int i = 0; i < records.length - 1; i++) {
          expect(
            records[i].timestamp.compareTo(records[i + 1].timestamp),
            greaterThanOrEqualTo(0),
            reason:
                'records[$i].timestamp should be >= records[${i + 1}].timestamp '
                '(trial $trial)',
          );
        }
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Task 6.4 — Property 7: Record deletion round-trip
  // ---------------------------------------------------------------------------
  // Feature: hyper-journal, Property 7: Record deletion round-trip
  // Validates: Requirements 2.5
  group('Property 7: Record deletion round-trip', () {
    setUp(() async {
      await DatabaseHelper().deleteAllRecords();
    });

    test('deleted record is absent from getRecords()', () async {
      final db = DatabaseHelper();
      final rng = Random(99);

      for (int i = 0; i < 100; i++) {
        final record = _randomRecord(rng);
        final id = await db.insertRecord(record);

        await db.deleteRecord(id);

        final records = await db.getRecords();
        final ids = records.map((r) => r.id).toList();
        expect(ids, isNot(contains(id)),
            reason: 'Deleted record id=$id should not appear in getRecords() '
                'at iteration $i');
      }
    });
  });
}
