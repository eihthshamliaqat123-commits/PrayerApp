import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('prayers_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE prayer_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        prayer_name TEXT NOT NULL,
        is_prayed INTEGER NOT NULL,
        UNIQUE(date, prayer_name)
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> fetchAllLogs() async {
    final db = await instance.database;
    return await db.query('prayer_logs');
  }

  Future<void> saveOrUpdatePrayer(
    String date,
    String prayerName,
    bool isPrayed,
  ) async {
    final db = await instance.database;
    final int intStatus = isPrayed ? 1 : 0;

    await db.insert('prayer_logs', {
      'date': date,
      'prayer_name': prayerName,
      'is_prayed': intStatus,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
