import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/health_record.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  /// Override the database path used by [_initDatabase].
  ///
  /// **For testing only.** Set to [inMemoryDatabasePath] (from
  /// `sqflite_common_ffi`) before the first test so each reset produces a
  /// fresh, isolated in-memory database.
  @visibleForTesting
  static String? databasePathOverride;

  /// Resets the cached database instance.
  ///
  /// **For testing only.** Call this in [tearDown] after overriding
  /// [databaseFactory] with [databaseFactoryFfi] so each test group
  /// gets a fresh in-memory database.
  @visibleForTesting
  static void resetForTesting() {
    _database = null;
    _needsCleanup = true;
  }

  /// Flag set by [resetForTesting] to indicate that the next database access
  /// should delete all records first.
  static bool _needsCleanup = false;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    if (_needsCleanup) {
      _needsCleanup = false;
      await _database!.delete('records');
    }
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // When databasePathOverride is set (test mode), use it with singleInstance: false
    // so each openDatabase call creates a fresh, isolated in-memory database.
    // In production, use the standard file-based path with singleInstance: true.
    if (databasePathOverride != null) {
      return await openDatabase(
        databasePathOverride!,
        version: 1,
        onCreate: _onCreate,
        singleInstance: false,
      );
    }
    final String path = join(await getDatabasesPath(), 'health_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        systolic INTEGER,
        diastolic INTEGER,
        pulse INTEGER,
        sugar REAL,
        timestamp TEXT,
        period TEXT
      )
    ''');
  }

  Future<int> insertRecord(HealthRecord record) async {
    Database db = await database;
    return await db.insert('records', record.toMap());
  }

  Future<List<HealthRecord>> getRecords() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('records', orderBy: 'timestamp DESC');
    return List.generate(maps.length, (i) => HealthRecord.fromMap(maps[i]));
  }

  Future<int> deleteRecord(int id) async {
    Database db = await database;
    return await db.delete('records', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllRecords() async {
    Database db = await database;
    return await db.delete('records');
  }

  Future<void> seedYearlyData() async {
    await deleteAllRecords();
    final random = Random();
    DateTime now = DateTime.now();

    for (int i = 365; i >= 0; i--) {
      DateTime day = now.subtract(Duration(days: i));
      
      // Morning record
      await insertRecord(HealthRecord(
        systolic: 115 + random.nextInt(25),
        diastolic: 70 + random.nextInt(20),
        pulse: 60 + random.nextInt(25),
        sugar: 4.5 + (random.nextDouble() * 2.5),
        timestamp: DateTime(day.year, day.month, day.day, 8, 0),
        period: 'morning',
      ));

      // Evening record
      await insertRecord(HealthRecord(
        systolic: 120 + random.nextInt(30),
        diastolic: 75 + random.nextInt(20),
        pulse: 65 + random.nextInt(25),
        timestamp: DateTime(day.year, day.month, day.day, 20, 0),
        period: 'evening',
      ));
    }
  }
}
