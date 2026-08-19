import '../../../database/app_database.dart';
import '../../../database/database_tables.dart';
import '../models/assignment.dart';
import '../models/assignment_subtask.dart';

class AssignmentsRepository {
  AssignmentsRepository(this._db);

  final AppDatabase _db;

  Future<List<Assignment>> getAssignments({
    AssignmentStatus? status,
    bool upcomingOnly = false,
    int? subjectId,
  }) async {
    final db = await _db.database;
    final where = <String>[];
    final args = <Object?>[];
    if (status != null) {
      where.add('${Columns.assignmentStatus} = ?');
      args.add(status.name);
    }
    if (subjectId != null) {
      where.add('${Columns.assignmentSubjectId} = ?');
      args.add(subjectId);
    }
    if (upcomingOnly) {
      where.add('${Columns.assignmentDue} IS NOT NULL');
      where.add('${Columns.assignmentDue} >= ?');
      args.add(DateTime.now().millisecondsSinceEpoch);
    }
    final rows = await db.query(
      Tables.assignments,
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: '${Columns.assignmentDue} ASC NULLS LAST, ${Columns.id} DESC',
    );
    return rows.map(Assignment.fromMap).toList();
  }

  Future<Assignment?> getAssignment(int id) async {
    final db = await _db.database;
    final rows = await db.query(Tables.assignments,
        where: '${Columns.id} = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Assignment.fromMap(rows.first);
  }

  Future<int> addAssignment(Assignment a) async {
    final db = await _db.database;
    return db.insert(Tables.assignments, a.toMap());
  }

  Future<void> updateAssignment(Assignment a) async {
    final db = await _db.database;
    await db.update(Tables.assignments, a.toMap(),
        where: '${Columns.id} = ?', whereArgs: [a.id]);
  }

  Future<void> deleteAssignment(int id) async {
    final db = await _db.database;
    await db.delete(Tables.assignments,
        where: '${Columns.id} = ?', whereArgs: [id]);
  }

  Future<void> toggleComplete(Assignment a) async {
    final isDone = a.status == AssignmentStatus.completed;
    final updated = a.copyWith(
      status: isDone ? AssignmentStatus.pending : AssignmentStatus.completed,
      completedAt:
          isDone ? null : DateTime.now(),
    );
    await updateAssignment(updated);
  }

  // -------------------------------------------------------------------
  // Subtasks (spec 06)
  // -------------------------------------------------------------------

  Future<List<AssignmentSubtask>> getSubtasks(int assignmentId) async {
    final db = await _db.database;
    final rows = await db.query(
      Tables.assignmentSubtasks,
      where: '${Columns.subtaskAssignmentId} = ?',
      whereArgs: [assignmentId],
      orderBy: '${Columns.subtaskOrder} ASC, ${Columns.id} ASC',
    );
    return rows.map(AssignmentSubtask.fromMap).toList();
  }

  Future<int> addSubtask(AssignmentSubtask s) async {
    final db = await _db.database;
    return db.insert(Tables.assignmentSubtasks, s.toMap());
  }

  Future<void> updateSubtask(AssignmentSubtask s) async {
    final db = await _db.database;
    await db.update(
      Tables.assignmentSubtasks,
      s.toMap(),
      where: '${Columns.id} = ?',
      whereArgs: [s.id],
    );
  }

  Future<void> deleteSubtask(int id) async {
    final db = await _db.database;
    await db.delete(Tables.assignmentSubtasks,
        where: '${Columns.id} = ?', whereArgs: [id]);
  }

  /// Returns a map of assignmentId -> [0..1] progress based on subtasks.
  /// Returns 0 if there are no subtasks (so cards fall back to title-only).
  Future<Map<int, double>> progressForAssignments(
      List<int> assignmentIds) async {
    final out = <int, double>{};
    if (assignmentIds.isEmpty) return out;
    final db = await _db.database;
    final placeholders = List.filled(assignmentIds.length, '?').join(',');
    final rows = await db.rawQuery('''
      SELECT ${Columns.subtaskAssignmentId} AS aid,
        SUM(CASE WHEN ${Columns.subtaskIsDone} = 1 THEN 1 ELSE 0 END) AS done,
        COUNT(*) AS total
      FROM ${Tables.assignmentSubtasks}
      WHERE ${Columns.subtaskAssignmentId} IN ($placeholders)
      GROUP BY ${Columns.subtaskAssignmentId}
    ''', assignmentIds);
    for (final r in rows) {
      final aid = r['aid'] as int;
      final done = (r['done'] as int?) ?? 0;
      final total = (r['total'] as int?) ?? 0;
      out[aid] = total == 0 ? 0.0 : done / total;
    }
    return out;
  }
}