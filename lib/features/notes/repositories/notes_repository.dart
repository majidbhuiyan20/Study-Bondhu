import '../../../database/app_database.dart';
import '../../../database/database_tables.dart';
import '../models/note.dart';

class NotesRepository {
  NotesRepository(this._db);
  final AppDatabase _db;

  Future<List<Note>> getNotes({int? subjectId}) async {
    final db = await _db.database;
    final rows = await db.query(
      Tables.notes,
      where: subjectId != null ? '${Columns.noteSubjectId} = ?' : null,
      whereArgs: subjectId != null ? [subjectId] : null,
      orderBy: '${Columns.updatedAt} DESC',
    );
    return rows.map(Note.fromMap).toList();
  }

  Future<Note?> getNote(int id) async {
    final db = await _db.database;
    final rows = await db.query(
      Tables.notes,
      where: '${Columns.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Note.fromMap(rows.first);
  }

  Future<int> addNote(Note n) async {
    final db = await _db.database;
    return db.insert(Tables.notes, n.toMap());
  }

  Future<void> updateNote(Note n) async {
    final db = await _db.database;
    await db.update(
      Tables.notes,
      n.toMap(),
      where: '${Columns.id} = ?',
      whereArgs: [n.id],
    );
  }

  Future<void> deleteNote(int id) async {
    final db = await _db.database;
    await db.delete(
      Tables.notes,
      where: '${Columns.id} = ?',
      whereArgs: [id],
    );
  }
}
