import '../../../database/app_database.dart';
import '../../../database/database_tables.dart';
import '../models/routine.dart';

class RoutinesRepository {
  RoutinesRepository(this._db);
  final AppDatabase _db;

  Future<List<Routine>> getRoutines({bool activeOnly = false}) async {
    final db = await _db.database;
    final rows = await db.query(
      Tables.routines,
      where: activeOnly ? '${Columns.routineActive} = 1' : null,
      orderBy: 'is_active DESC, id DESC',
    );
    return rows.map(Routine.fromMap).toList();
  }

  Future<List<Routine>> getForDay(DateTime day) async {
    final all = await getRoutines(activeOnly: true);
    return all.where((r) => r.isOnDay(day)).toList();
  }

  Future<int> addRoutine(Routine r) async {
    final db = await _db.database;
    return db.insert(Tables.routines, r.toMap());
  }

  Future<void> updateRoutine(Routine r) async {
    final db = await _db.database;
    await db.update(
      Tables.routines,
      r.toMap(),
      where: '${Columns.id} = ?',
      whereArgs: [r.id],
    );
  }

  Future<void> deleteRoutine(int id) async {
    final db = await _db.database;
    await db.delete(
      Tables.routines,
      where: '${Columns.id} = ?',
      whereArgs: [id],
    );
  }

  Future<void> markDoneToday(int id) async {
    final db = await _db.database;
    await db.update(
      Tables.routines,
      {'last_done_date': DateTime.now().millisecondsSinceEpoch},
      where: '${Columns.id} = ?',
      whereArgs: [id],
    );
  }
}