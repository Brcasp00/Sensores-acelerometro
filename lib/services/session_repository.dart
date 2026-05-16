import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/workout_session.dart';

class SessionRepository {
  static const _dbName = 'squat_counter.db';
  static const _table = 'sessions';

  Database? _db;

  Future<Database> _open() async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            config TEXT NOT NULL,
            startedAt TEXT NOT NULL,
            finishedAt TEXT,
            events TEXT NOT NULL,
            totalReps INTEGER NOT NULL,
            totalDurationMs INTEGER NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  Future<int> insertSession(WorkoutSession session) async {
    final db = await _open();
    final map = session.toDbMap()..remove('id');
    return db.insert(_table, map);
  }

  Future<List<WorkoutSession>> listSessions({int limit = 50}) async {
    final db = await _open();
    final rows = await db.query(
      _table,
      orderBy: 'startedAt DESC',
      limit: limit,
    );
    return rows.map(WorkoutSession.fromDbMap).toList();
  }

  Future<WorkoutSession?> getSession(int id) async {
    final db = await _open();
    final rows = await db.query(_table, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return WorkoutSession.fromDbMap(rows.first);
  }

  Future<void> deleteSession(int id) async {
    final db = await _open();
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await _open();
    await db.delete(_table);
  }
}
