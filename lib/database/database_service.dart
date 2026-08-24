import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  static Database? _database;

  // ✅ INSERT FULL BEHAVIOR
  static Future<void> insertBehavior(Map<String, dynamic> data) async {
    final db = await database;

    await db.insert(
      'behavior',
      data,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // ✅ UPDATE MOOD (LATEST ENTRY)
  static Future<void> insertMood(int mood) async {
    final db = await database;

    List<Map<String, dynamic>> result =
    await db.query('behavior', orderBy: 'id DESC', limit: 1);

    if (result.isNotEmpty) {
      int id = result.first['id'];

      await db.update(
        'behavior',
        {'mood': mood},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // ✅ FETCH LAST 10 ENTRIES (FOR STABILITY)
  static Future<List<Map<String, dynamic>>> getLast10() async {
    final db = await database;

    return await db.query(
      'behavior',
      orderBy: 'id DESC',
      limit: 10,
    );
  }

  // ✅ FETCH TOTAL COUNT
  static Future<int> getCount() async {
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM behavior')) ?? 0;
  }

  // ✅ DATABASE INSTANCE
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  // ✅ CREATE DATABASE
  static Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'behavior.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE behavior(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sleep REAL,
  work REAL,
  study REAL,
  workout REAL,
  food INTEGER,
  mealSkipped INTEGER,
  routine INTEGER,
  screenTime REAL,
  calls INTEGER,
  maxCallDuration REAL,
  mood INTEGER,
  date TEXT
)
''');
      },
    );
  }

  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('behavior');
  }

  // ✅ FACTORY RESET LOGIC
  static Future<void> factoryReset() async {
    // 1. Clear Database
    await clearAllData();

    // 2. Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 3. Reset _database instance to force re-init if needed
    _database = null;
  }
}
