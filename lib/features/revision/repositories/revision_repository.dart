import '../../../database/app_database.dart';
import '../../../database/database_tables.dart';
import '../models/revision_item.dart';

class RevisionRepository {
  RevisionRepository(this._db);

  final AppDatabase _db;

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
}