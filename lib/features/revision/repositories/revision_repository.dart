import '../../../database/app_database.dart';
import '../../../database/database_tables.dart';
import '../models/revision_item.dart';

class RevisionRepository {
  RevisionRepository(this._db);

  final AppDatabase _db;

  // ----- Reads -----

  Future<List<RevisionItem>> getAll({RevisionStatus? status}) async {
    final db = await _db.database;
    final rows = await db.query(
      Tables.revisionItems,
      where: status != null ? '${Columns.revisionStatus} = ?' : null,
      whereArgs: status != null ? [status.name] : null,
      orderBy: '${Columns.revisionDate} ASC',
    );
    return rows.map(RevisionItem.fromMap).toList();
  }

  /// SQL-backed pending query. Use this from the revision view instead of
  /// `getAll(status: pending)` so we never accidentally widen to all rows.
  Future<List<RevisionItem>> getPending({int? limit}) async {
    final db = await _db.database;
    final rows = await db.query(
      Tables.revisionItems,
      where: '${Columns.revisionStatus} = ?',
      whereArgs: [RevisionStatus.pending.name],
      orderBy: '${Columns.revisionDate} ASC',
      limit: limit,
    );
    return rows.map(RevisionItem.fromMap).toList();
  }

  Future<RevisionItem?> getById(int id) async {
    final db = await _db.database;
    final rows = await db.query(
      Tables.revisionItems,
      where: '${Columns.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return RevisionItem.fromMap(rows.first);
  }

  // ----- Writes -----

  Future<int> addRevision(RevisionItem r) async {
    final db = await _db.database;
    return db.insert(Tables.revisionItems, r.toMap());
  }

  Future<void> updateRevision(RevisionItem r) async {
    final db = await _db.database;
    await db.update(Tables.revisionItems, r.toMap(),
        where: '${Columns.id} = ?', whereArgs: [r.id]);
  }

  Future<void> deleteRevision(int id) async {
    final db = await _db.database;
    await db.delete(Tables.revisionItems,
        where: '${Columns.id} = ?', whereArgs: [id]);
  }

  /// Atomically flips [currentId] from `pending` → `completed` while
  /// persisting [rating], then upserts the next pending revision for the
  /// same topic (update if one already exists, otherwise insert).
  ///
  /// Returns `true` if the original row was transitioned; `false` if it
  /// was already completed/missed (i.e. idempotent no-op).
  Future<bool> markCompletedWithFollowup({
    required int currentId,
    required int rating,
    required RevisionItem next,
  }) async {
    final db = await _db.database;
    return db.transaction<bool>((txn) async {
      // 1) Status-guarded flip. If 0 rows updated, this is a duplicate
      //    tap on an already-completed revision → no-op.
      final updated = await txn.update(
        Tables.revisionItems,
        {
          Columns.revisionStatus: RevisionStatus.completed.name,
          Columns.revisionRating: rating,
        },
        where: '${Columns.id} = ? AND ${Columns.revisionStatus} = ?',
        whereArgs: [currentId, RevisionStatus.pending.name],
      );
      if (updated == 0) return false;
      if (next.topicId == null) return true;

      // 2) Upsert follow-up pending row for the same topic. Prevents the
      //    "tap Strong twice → 3 new rows" bug.
      final existingIdRows = await txn.query(
        Tables.revisionItems,
        columns: [Columns.id],
        where: '${Columns.revisionTopicId} = ? '
            'AND ${Columns.revisionStatus} = ? '
            'AND ${Columns.id} <> ?',
        whereArgs: [
          next.topicId,
          RevisionStatus.pending.name,
          currentId,
        ],
        limit: 1,
      );

      final map = next.toMap();
      if (existingIdRows.isNotEmpty) {
        final existingId = existingIdRows.first[Columns.id] as int;
        await txn.update(
          Tables.revisionItems,
          map,
          where: '${Columns.id} = ?',
          whereArgs: [existingId],
        );
      } else {
        await txn.insert(Tables.revisionItems, map);
      }
      return true;
    });
  }

  /// Idempotent upsert of the pending follow-up row for [topicId].
  /// If a pending row already exists, its scheduled date + interval are
  /// updated in place. Otherwise a new row is inserted.
  Future<void> replacePendingForTopic({
    required int topicId,
    required int? subjectId,
    required DateTime scheduledDate,
    required int intervalDays,
    DateTime? createdAt,
  }) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      final existing = await txn.query(
        Tables.revisionItems,
        columns: [Columns.id],
        where: '${Columns.revisionTopicId} = ? '
            'AND ${Columns.revisionStatus} = ?',
        whereArgs: [topicId, RevisionStatus.pending.name],
        limit: 1,
      );
      final ts = scheduledDate.millisecondsSinceEpoch;
      final createdMs =
          (createdAt ?? DateTime.now()).millisecondsSinceEpoch;

      if (existing.isNotEmpty) {
        final id = existing.first[Columns.id] as int;
        await txn.update(
          Tables.revisionItems,
          {
            Columns.revisionDate: ts,
            Columns.revisionInterval: intervalDays,
          },
          where: '${Columns.id} = ?',
          whereArgs: [id],
        );
      } else {
        await txn.insert(Tables.revisionItems, {
          'subject_id': subjectId,
          'topic_id': topicId,
          'scheduled_date': ts,
          'status': RevisionStatus.pending.name,
          'interval_days': intervalDays,
          'rating': null,
          'created_at': createdMs,
        });
      }
    });
  }

  /// Bulk fetch by id, used by views that pre-load pending rows and need
  /// O(1) map lookups. Avoids the O(N) full-table scan pattern.
  Future<Map<int, RevisionItem>> getByIds(Iterable<int> ids) async {
    if (ids.isEmpty) return const {};
    final list = ids.toList();
    final db = await _db.database;
    final placeholders = List.filled(list.length, '?').join(',');
    final rows = await db.query(
      Tables.revisionItems,
      where: '${Columns.id} IN ($placeholders)',
      whereArgs: list,
    );
    return {
      for (final r in rows.map(RevisionItem.fromMap))
        if (r.id != null) r.id!: r,
    };
  }
}