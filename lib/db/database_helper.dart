import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/habit_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    _database ??= await _initDB("habit_tracker.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        highestStreak INTEGER NOT NULL,
        currentStreak INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        userId INTEGER,
        FOREIGN KEY(userId) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE habit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habitId INTEGER NOT NULL,
        date TEXT NOT NULL,
        UNIQUE(habitId, date),
        FOREIGN KEY(habitId) REFERENCES habits(id)
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE habits ADD COLUMN currentStreak INTEGER NOT NULL DEFAULT 0');
    }
  }

  // ------------------- HABIT METHODS -------------------

  Future<int> insertHabit(Habit habit) async {
    final db = await instance.database;
    return await db.insert('habits', habit.toMap());
  }

  Future<List<Habit>> getAllHabits() async {
    final db = await instance.database;
    final result = await db.query('habits', orderBy: 'createdAt DESC');
    return result.map((json) => Habit.fromMap(json)).toList();
  }

  Future<int> deleteHabit(int id) async {
    final db = await instance.database;
    await db.delete('habit_logs', where: 'habitId = ?', whereArgs: [id]);
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------- LOGS -------------------

  Future<void> addHabitLog(int habitId, String date) async {
    final db = await instance.database;
    await db.insert('habit_logs', {
      'habitId': habitId,
      'date': date,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeHabitLog(int habitId, String date) async {
    final db = await instance.database;
    await db.delete(
      'habit_logs',
      where: 'habitId = ? AND date = ?',
      whereArgs: [habitId, date],
    );
  }

  Future<List<String>> getHabitLogs(int habitId) async {
    final db = await instance.database;
    final result = await db.query(
      'habit_logs',
      where: 'habitId = ?',
      whereArgs: [habitId],
    );
    return result.map((row) => row['date'] as String).toList();
  }

  // ------------------- STREAKS -------------------

  Future<void> updateStreak(int habitId) async {
    final db = await instance.database;
    final logs = await getHabitLogs(habitId);

    List<DateTime> dates = logs.map((d) => DateTime.parse(d)).toList();
    dates.sort();

    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? prev;
    DateTime today = DateTime.now();
    bool stillGoing = false;

    for (var date in dates) {
      if (prev == null) {
        currentStreak = 1;
      } else if (date.difference(prev).inDays == 1) {
        currentStreak++;
      } else {
        currentStreak = 1;
      }

      if (currentStreak > maxStreak) maxStreak = currentStreak;
      prev = date;
    }

    // Check if the last logged day is yesterday or today
    if (dates.isNotEmpty) {
      DateTime lastLog = dates.last;
      final daysDiff = today.difference(lastLog).inDays;
      stillGoing = daysDiff == 0 || daysDiff == 1;
    }

    await db.update(
      'habits',
      {
        'highestStreak': maxStreak,
        'currentStreak': stillGoing ? currentStreak : 0,
      },
      where: 'id = ?',
      whereArgs: [habitId],
    );
  }

  Future<int> getHighestStreak(int habitId) async {
    final db = await instance.database;
    final result = await db.query(
      'habits',
      columns: ['highestStreak'],
      where: 'id = ?',
      whereArgs: [habitId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['highestStreak'] as int;
    }
    return 0;
  }

  Future<int> getCurrentStreak(int habitId) async {
    final db = await instance.database;
    final result = await db.query(
      'habits',
      columns: ['currentStreak'],
      where: 'id = ?',
      whereArgs: [habitId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['currentStreak'] as int;
    }
    return 0;
  }

  // ------------------- USER AUTH -------------------

  Future<int> registerUser(String email, String password) async {
    final db = await instance.database;
    return await db.insert('users', {
      'email': email.trim(),
      'password': password.trim(),
    });
  }

  Future<int?> loginUser(String email, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email.trim(), password.trim()],
    );
    if (result.isNotEmpty) {
      return result.first['id'] as int;
    }
    return null;
  }
}
