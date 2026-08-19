import '../../../database/app_database.dart';
import '../../../database/database_tables.dart';
import '../models/study_session.dart';

class StudyRepository {
  StudyRepository(this._db);
  final AppDatabase _db;

  Future<List<StudySession>> getSessions({
    DateTime? from,
    DateTime? to,
    int? subjectId,
  }) async {
    final db = await _db.database;
    final where = <String>[];
    final args = <Object?>[];
    if (from != null) {
      where.add('${Columns.sessionStart} >= ?');
      args.add(from.millisecondsSinceEpoch);
    }
    if (to != null) {
      where.add('${Columns.sessionStart} < ?');
      args.add(to.millisecondsSinceEpoch);
    }
    if (subjectId != null) {
      where.add('${Columns.sessionSubjectId} = ?');
      args.add(subjectId);
    }
    final rows = await db.query(
      Tables.studySessions,
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: '${Columns.sessionStart} DESC',
    );
    return rows.map(StudySession.fromMap).toList();
  }

  Future<StudySession?> getSession(int id) async {
    final db = await _db.database;
    final rows = await db.query(
      Tables.studySessions,
      where: '${Columns.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return StudySession.fromMap(rows.first);
  }

  Future<int> addSession(StudySession s) async {
    final db = await _db.database;
    return db.insert(Tables.studySessions, s.toMap());
  }

  Future<void> updateSession(StudySession s) async {
    final db = await _db.database;
    await db.update(
      Tables.studySessions,
      s.toMap(),
      where: '${Columns.id} = ?',
      whereArgs: [s.id],
    );
  }

  Future<void> deleteSession(int id) async {
    final db = await _db.database;
    await db.delete(
      Tables.studySessions,
      where: '${Columns.id} = ?',
      whereArgs: [id],
    );
  }

  /// Total study minutes per day for the last [days] days.
  Future<List<DailyStudySummary>> getDailyTotals(int days) async {
    final db = await _db.database;
    final since = DateTime.now()
        .subtract(Duration(days: days))
        .millisecondsSinceEpoch;
    final rows = await db.rawQuery(
      'SELECT start_time, duration_seconds FROM ${Tables.studySessions} WHERE start_time >= ?',
      [since],
    );
    final byDay = <DateTime, int>{};
    for (final row in rows) {
      final start =
          DateTime.fromMillisecondsSinceEpoch(row['start_time'] as int);
      final d = DateTime(start.year, start.month, start.day);
      byDay[d] = (byDay[d] ?? 0) + (row['duration_seconds'] as int);
    }
    final today = DateTime.now();
    final list = <DailyStudySummary>[];
    for (int i = days - 1; i >= 0; i--) {
      final day = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
      list.add(DailyStudySummary(
        date: day,
        seconds: byDay[day] ?? 0,
      ));
    }
    return list;
  }

  Future<int> totalSecondsSince(DateTime from) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      'SELECT SUM(duration_seconds) AS total FROM ${Tables.studySessions} WHERE start_time >= ?',
      [from.millisecondsSinceEpoch],
    );
    return (rows.first['total'] as int?) ?? 0;
  }

  Future<Map<int, int>> totalSecondsBySubjectSince(DateTime from) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      'SELECT subject_id, SUM(duration_seconds) AS total FROM ${Tables.studySessions} WHERE start_time >= ? GROUP BY subject_id',
      [from.millisecondsSinceEpoch],
    );
    final out = <int, int>{};
    for (final r in rows) {
      final sid = r['subject_id'];
      if (sid == null) continue;
      out[sid as int] = (r['total'] as int?) ?? 0;
    }
    return out;
  }
}

class DailyStudySummary {
  final DateTime date;
  final int seconds;
  const DailyStudySummary({required this.date, required this.seconds});
  Duration get duration => Duration(seconds: seconds);
}
