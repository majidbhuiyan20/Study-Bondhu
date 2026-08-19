import '../../../database/app_database.dart';
import '../../../database/database_tables.dart';
import '../models/attendance_record.dart';

class AttendanceRepository {
  AttendanceRepository(this._db);

  final AppDatabase _db;

  Future<List<AttendanceRecord>> getAttendanceForSubject(int subjectId) async {
    final db = await _db.database;
    final rows = await db.query(
      Tables.attendance,
      where: '${Columns.attendanceSubjectId} = ?',
      whereArgs: [subjectId],
      orderBy: '${Columns.attendanceDate} DESC',
    );
    return rows.map(AttendanceRecord.fromMap).toList();
  }

  Future<int> addAttendance(AttendanceRecord r) async {
    final db = await _db.database;
    return db.insert(Tables.attendance, r.toMap());
  }

  Future<void> updateAttendance(AttendanceRecord r) async {
    final db = await _db.database;
    await db.update(Tables.attendance, r.toMap(),
        where: '${Columns.id} = ?', whereArgs: [r.id]);
  }

  Future<void> deleteAttendance(int id) async {
    final db = await _db.database;
    await db.delete(Tables.attendance,
        where: '${Columns.id} = ?', whereArgs: [id]);
  }

  /// Returns a map of subjectId -> attendance stats
  Future<Map<int, AttendanceStats>> getAllStats() async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT subject_id,
        SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) AS present_count,
        SUM(CASE WHEN status = 'late' THEN 1 ELSE 0 END) AS late_count,
        SUM(CASE WHEN status = 'absent' THEN 1 ELSE 0 END) AS absent_count,
        COUNT(*) AS total
      FROM ${Tables.attendance}
      GROUP BY subject_id
    ''');
    final result = <int, AttendanceStats>{};
    for (final row in rows) {
      final sid = row['subject_id'] as int;
      final total = (row['total'] as int?) ?? 0;
      final present = (row['present_count'] as int?) ?? 0;
      final late = (row['late_count'] as int?) ?? 0;
      final absent = (row['absent_count'] as int?) ?? 0;
      final counted = present + late;
      final pct = total == 0 ? 0.0 : counted / total * 100;
      result[sid] = AttendanceStats(
        present: present,
        late: late,
        absent: absent,
        total: total,
        percent: pct,
      );
    }
    return result;
  }
}

class AttendanceStats {
  final int present;
  final int late;
  final int absent;
  final int total;
  final double percent;
  const AttendanceStats({
    required this.present,
    required this.late,
    required this.absent,
    required this.total,
    required this.percent,
  });

  int get attended => present + late;
}