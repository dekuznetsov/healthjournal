import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/health_record.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'health_tracker.db');
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
