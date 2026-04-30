/// Shared test infrastructure for hyper_journal tests.
///
/// Sub-task 1.1: SharedPreferences mock support.
/// Sub-task 1.2: sqflite_common_ffi in-memory database helper.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Call this in [setUp] to reset SharedPreferences to an empty state.
///
/// Example:
/// ```dart
/// setUp(() async {
///   await setupMockSharedPreferences();
/// });
/// ```
Future<void> setupMockSharedPreferences([
  Map<String, Object> initialValues = const {},
]) async {
  SharedPreferences.setMockInitialValues(initialValues);
}

/// Initialises sqflite_common_ffi and returns an open in-memory [Database]
/// with the `records` table created.
///
/// Call [db.close()] in [tearDown] to release resources.
///
/// Example:
/// ```dart
/// late Database db;
/// setUp(() async { db = await openTestDatabase(); });
/// tearDown(() async { await db.close(); });
/// ```
Future<Database> openTestDatabase() async {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;
  final db = await factory.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE records(
            id        INTEGER PRIMARY KEY AUTOINCREMENT,
            systolic  INTEGER NOT NULL,
            diastolic INTEGER NOT NULL,
            pulse     INTEGER NOT NULL,
            sugar     REAL,
            timestamp TEXT NOT NULL,
            period    TEXT NOT NULL
          )
        ''');
      },
    ),
  );
  return db;
}

/// A convenience [TimeOfDay] factory for tests.
TimeOfDay tod(int hour, int minute) => TimeOfDay(hour: hour, minute: minute);
