import '../../../database/app_database.dart';
import '../../../database/database_tables.dart';
import '../models/semester.dart';
import '../models/subject.dart';
import '../models/syllabus_item.dart';
import '../models/topic.dart';

class SubjectsRepository {
  SubjectsRepository(this._db);

  final AppDatabase _db;

  // ----- Semesters -----
  Future<List<Semester>> getSemesters({int? profileId}) async {
    final db = await _db.database;
    final rows = await db.query(
      Tables.semesters,
      where: profileId != null ? 'profile_id = ?' : null,
      whereArgs: profileId != null ? [profileId] : null,
      orderBy: 'is_active DESC, start_date DESC NULLS LAST, id DESC',
    );
    return rows.map(Semester.fromMap).toList();
  }

  /// Returns the active semester for the given profile (or global if
  /// [profileId] is null). Falls back to the first semester if none is
  /// explicitly marked active.
  Future<Semester?> getActiveSemester({int? profileId}) async {
    final list = await getSemesters(profileId: profileId);
    for (final s in list) {
      if (s.isActive) return s;
    }
    return list.isEmpty ? null : list.first;
  }

  Future<int> addSemester(Semester s) async {
    final db = await _db.database;
    return db.insert(Tables.semesters, s.toMap());
  }

  Future<void> updateSemester(Semester s) async {
    final db = await _db.database;
    await db.update(Tables.semesters, s.toMap(),
        where: '${Columns.id} = ?', whereArgs: [s.id]);
  }

  Future<void> deleteSemester(int id) async {
    final db = await _db.database;
    await db.delete(Tables.semesters,
        where: '${Columns.id} = ?', whereArgs: [id]);
  }

  Future<void> setActiveSemester(int id) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.update(Tables.semesters, {'is_active': 0});
      await txn.update(Tables.semesters, {'is_active': 1},
          where: '${Columns.id} = ?', whereArgs: [id]);
    });
  }

  // ----- Subjects -----
  Future<List<Subject>> getSubjects({int? semesterId}) async {
    final db = await _db.database;
    final rows = await db.query(
      Tables.subjects,
      where: semesterId != null
          ? '${Columns.subjectSemesterId} = ?'
          : null,
      whereArgs: semesterId != null ? [semesterId] : null,
      orderBy: 'name ASC',
    );
    return rows.map(Subject.fromMap).toList();
  }

  Future<Subject?> getSubject(int id) async {
    final db = await _db.database;
    final rows = await db.query(Tables.subjects,
        where: '${Columns.id} = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Subject.fromMap(rows.first);
  }

  Future<int> addSubject(Subject s) async {
    final db = await _db.database;
    return db.insert(Tables.subjects, s.toMap());
  }

  Future<void> updateSubject(Subject s) async {
    final db = await _db.database;
    await db.update(Tables.subjects, s.toMap(),
        where: '${Columns.id} = ?', whereArgs: [s.id]);
  }

  Future<void> deleteSubject(int id) async {
    final db = await _db.database;
    await db.delete(Tables.subjects,
        where: '${Columns.id} = ?', whereArgs: [id]);
  }

  // ----- Topics -----
  Future<List<Topic>> getTopics(int subjectId) async {
    final db = await _db.database;
    final rows = await db.query(
      Tables.topics,
      where: '${Columns.topicSubjectId} = ?',
      whereArgs: [subjectId],
      orderBy: 'sort_order ASC, id ASC',
    );
    return rows.map(Topic.fromMap).toList();
  }

  Future<List<Topic>> getAllTopics() async {
    final db = await _db.database;
    final rows = await db.query(Tables.topics);
    return rows.map(Topic.fromMap).toList();
  }

  /// O(1) single-row lookup. Use this instead of fetching all topics and
  /// iterating when only one is needed — e.g. inside the revision engine.
  Future<Topic?> getTopicById(int id) async {
    final db = await _db.database;
    final rows = await db.query(Tables.topics,
        where: '${Columns.id} = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Topic.fromMap(rows.first);
  }

  /// Bulk lookup, used by the revision view to render rows in O(1)
  /// rather than scanning the entire topics table per row.
  Future<Map<int, Topic>> getTopicsByIds(Iterable<int> ids) async {
    if (ids.isEmpty) return const {};
    final list = ids.toList();
    final db = await _db.database;
    final placeholders = List.filled(list.length, '?').join(',');
    final rows = await db.query(
      Tables.topics,
      where: '${Columns.id} IN ($placeholders)',
      whereArgs: list,
    );
    return {
      for (final t in rows.map(Topic.fromMap))
        if (t.id != null) t.id!: t,
    };
  }

  Future<Map<int, Subject>> getSubjectsByIds(Iterable<int> ids) async {
    if (ids.isEmpty) return const {};
    final list = ids.toList();
    final db = await _db.database;
    final placeholders = List.filled(list.length, '?').join(',');
    final rows = await db.query(
      Tables.subjects,
      where: '${Columns.id} IN ($placeholders)',
      whereArgs: list,
    );
    return {
      for (final s in rows.map(Subject.fromMap))
        if (s.id != null) s.id!: s,
    };
  }

  Future<int> addTopic(Topic t) async {
    final db = await _db.database;
    return db.insert(Tables.topics, t.toMap());
  }

  Future<void> updateTopic(Topic t) async {
    final db = await _db.database;
    await db.update(Tables.topics, t.toMap(),
        where: '${Columns.id} = ?', whereArgs: [t.id]);
  }

  Future<void> deleteTopic(int id) async {
    final db = await _db.database;
    await db.delete(Tables.topics,
        where: '${Columns.id} = ?', whereArgs: [id]);
  }

  // ----- Syllabus -----
  Future<List<SyllabusItem>> getSyllabus(int subjectId) async {
    final db = await _db.database;
    final rows = await db.query(
      Tables.syllabusItems,
      where: '${Columns.syllabusSubjectId} = ?',
      whereArgs: [subjectId],
      orderBy: 'is_done ASC, order_index ASC, id ASC',
    );
    return rows.map(SyllabusItem.fromMap).toList();
  }

  Future<int> addSyllabus(SyllabusItem item) async {
    final db = await _db.database;
    return db.insert(Tables.syllabusItems, item.toMap());
  }

  Future<void> updateSyllabus(SyllabusItem item) async {
    final db = await _db.database;
    await db.update(Tables.syllabusItems, item.toMap(),
        where: '${Columns.id} = ?', whereArgs: [item.id]);
  }

  Future<void> deleteSyllabus(int id) async {
    final db = await _db.database;
    await db.delete(Tables.syllabusItems,
        where: '${Columns.id} = ?', whereArgs: [id]);
  }

  /// Atomically rewrite `order_index` for every syllabus item belonging to
  /// `subjectId`. Called after a drag-reorder so the list survives restart.
  Future<void> replaceSyllabusForSubject(
    int subjectId,
    List<SyllabusItem> ordered,
  ) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      for (var i = 0; i < ordered.length; i++) {
        final s = ordered[i].copyWith(orderIndex: i);
        await txn.update(
          Tables.syllabusItems,
          s.toMap(),
          where: '${Columns.id} = ?',
          whereArgs: [s.id],
        );
      }
    });
  }
}