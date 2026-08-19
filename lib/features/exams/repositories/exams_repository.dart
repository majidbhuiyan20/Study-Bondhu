import '../../../database/app_database.dart';
import '../../../database/database_tables.dart';
import '../models/exam.dart';

class ExamsRepository {
  ExamsRepository(this._db);

  final AppDatabase _db;

  Future<List<Exam>> getExams({
    bool upcomingOnly = false,
    int? subjectId,
  }) async {
    final db = await _db.database;
    final where = <String>[];
    final args = <Object?>[];
    if (upcomingOnly) {
      where.add('${Columns.examDate} >= ?');
      args.add(DateTime.now().millisecondsSinceEpoch -
          const Duration(days: 1).inMilliseconds);
    }
    if (subjectId != null) {
      where.add('${Columns.examSubjectId} = ?');
      args.add(subjectId);
    }
    final rows = await db.query(
      Tables.exams,
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: '${Columns.examDate} ASC, ${Columns.id} ASC',
    );
    return rows.map(Exam.fromMap).toList();
  }

  Future<Exam?> getExam(int id) async {
    final db = await _db.database;
    final rows = await db.query(Tables.exams,
        where: '${Columns.id} = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Exam.fromMap(rows.first);
  }

  Future<int> addExam(Exam e) async {
    final db = await _db.database;
    return db.insert(Tables.exams, e.toMap());
  }

  Future<void> updateExam(Exam e) async {
    final db = await _db.database;
    await db.update(Tables.exams, e.toMap(),
        where: '${Columns.id} = ?', whereArgs: [e.id]);
  }

  Future<void> deleteExam(int id) async {
    final db = await _db.database;
    await db.delete(Tables.exams,
        where: '${Columns.id} = ?', whereArgs: [id]);
  }
}