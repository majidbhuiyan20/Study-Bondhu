import '../../../database/app_database.dart';
import '../../../database/database_tables.dart';
import '../models/local_resource.dart';

class ResourcesRepository {
  ResourcesRepository(this._db);
  final AppDatabase _db;

  Future<List<LocalResource>> getResources({int? subjectId}) async {
    final db = await _db.database;
    final rows = await db.query(
      Tables.resources,
      where: subjectId != null
          ? '${Columns.classSubjectId} = ?'
          : null,
      whereArgs: subjectId != null ? [subjectId] : null,
      orderBy: '${Columns.createdAt} DESC',
    );
    return rows.map(LocalResource.fromMap).toList();
  }

  Future<int> addResource(LocalResource r) async {
    final db = await _db.database;
    return db.insert(Tables.resources, r.toMap());
  }

  Future<void> updateResource(LocalResource r) async {
    final db = await _db.database;
    await db.update(
      Tables.resources,
      r.toMap(),
      where: '${Columns.id} = ?',
      whereArgs: [r.id],
    );
  }

  Future<void> deleteResource(int id) async {
    final db = await _db.database;
    await db.delete(
      Tables.resources,
      where: '${Columns.id} = ?',
      whereArgs: [id],
    );
  }
}