import '../../../database/app_database.dart';
import '../../../database/database_tables.dart';
import '../models/goal.dart';

class AnalyticsRepository {
  AnalyticsRepository(this._db);

  final AppDatabase _db;

  // ----- Goals -----
  Future<List<Goal>> getGoals() async {
    final db = await _db.database;
    final rows = await db.query(Tables.goals,
        orderBy: '${Columns.createdAt} DESC');
    return rows.map(Goal.fromMap).toList();
  }

  Future<int> addGoal(Goal g) async {
    final db = await _db.database;
    return db.insert(Tables.goals, g.toMap());
  }

  Future<void> updateGoal(Goal g) async {
    final db = await _db.database;
    await db.update(Tables.goals, g.toMap(),
        where: '${Columns.id} = ?', whereArgs: [g.id]);
  }

  Future<void> deleteGoal(int id) async {
    final db = await _db.database;
    await db.delete(Tables.goals,
        where: '${Columns.id} = ?', whereArgs: [id]);
  }
}