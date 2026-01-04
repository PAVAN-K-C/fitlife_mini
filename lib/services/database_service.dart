import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/workout.dart';
import '../models/reminder.dart';
import '../models/user.dart';

class DatabaseService {
  static const String _databaseName = 'fitlife_mini.db';
  static const int _databaseVersion = 1;

  static const String workoutTable = 'workouts';
  static const String reminderTable = 'reminders';
  static const String userTable = 'users';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE $userTable (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password TEXT,
        isGuest INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    // Create workouts table
    await db.execute('''
      CREATE TABLE $workoutTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        duration INTEGER NOT NULL,
        caloriesBurned INTEGER NOT NULL,
        date TEXT NOT NULL,
        description TEXT
      )
    ''');

    // Create reminders table
    await db.execute('''
      CREATE TABLE $reminderTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        scheduledTime TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        frequency TEXT NOT NULL DEFAULT 'daily'
      )
    ''');
  }

  // User operations
  Future<void> saveUser(User user) async {
    final db = await database;
    await db.insert(
      userTable,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUser(String id) async {
    final db = await database;
    final maps = await db.query(
      userTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      userTable,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Workout operations
  Future<void> addWorkout(Workout workout) async {
    final db = await database;
    await db.insert(
      workoutTable,
      workout.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Workout>> getAllWorkouts() async {
    final db = await database;
    final maps = await db.query(
      workoutTable,
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) => Workout.fromMap(maps[i]));
  }

  Future<List<Workout>> getWorkoutsByType(String type) async {
    final db = await database;
    final maps = await db.query(
      workoutTable,
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) => Workout.fromMap(maps[i]));
  }

  Future<List<Workout>> getWorkoutsByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final maps = await db.query(
      workoutTable,
      where: 'date >= ? AND date < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) => Workout.fromMap(maps[i]));
  }

  Future<void> updateWorkout(Workout workout) async {
    final db = await database;
    await db.update(
      workoutTable,
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  Future<void> deleteWorkout(String id) async {
    final db = await database;
    await db.delete(
      workoutTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Reminder operations
  Future<void> addReminder(Reminder reminder) async {
    final db = await database;
    await db.insert(
      reminderTable,
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Reminder>> getAllReminders() async {
    final db = await database;
    final maps = await db.query(reminderTable);

    return List.generate(maps.length, (i) => Reminder.fromMap(maps[i]));
  }

  Future<void> updateReminder(Reminder reminder) async {
    final db = await database;
    await db.update(
      reminderTable,
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<void> deleteReminder(String id) async {
    final db = await database;
    await db.delete(
      reminderTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Statistics operations
  Future<int> getTotalCaloriesToday() async {
    final db = await database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery(
      'SELECT SUM(caloriesBurned) as total FROM $workoutTable WHERE date >= ? AND date < ?',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    return (result.first['total'] as int?) ?? 0;
  }

  Future<int> getWorkoutCountToday() async {
    final db = await database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $workoutTable WHERE date >= ? AND date < ?',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    return (result.first['count'] as int?) ?? 0;
  }
}
