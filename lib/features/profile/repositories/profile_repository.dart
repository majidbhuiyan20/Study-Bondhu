import '../../../database/app_database.dart';
import '../../../database/database_tables.dart';
import '../models/profile.dart';

class ProfileRepository {
  ProfileRepository(this._db);
  final AppDatabase _db;

  Future<List<Profile>> getProfiles() async {
    final db = await _db.database;
    final rows = await db.query(Tables.profiles, orderBy: 'id ASC');
    return rows.map(Profile.fromMap).toList();
  }

  Future<Profile?> getProfile(int id) async {
    final db = await _db.database;
    final rows = await db.query(
      Tables.profiles,
      where: '${Columns.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Profile.fromMap(rows.first);
  }

  Future<int> addProfile(Profile p) async {
    final db = await _db.database;
    return db.insert(Tables.profiles, p.toMap());
  }

  Future<void> updateProfile(Profile p) async {
    final db = await _db.database;
    await db.update(
      Tables.profiles,
      p.toMap(),
      where: '${Columns.id} = ?',
      whereArgs: [p.id],
    );
  }

  Future<void> deleteProfile(int id) async {
    final db = await _db.database;
    await db.delete(
      Tables.profiles,
      where: '${Columns.id} = ?',
      whereArgs: [id],
    );
  }
}