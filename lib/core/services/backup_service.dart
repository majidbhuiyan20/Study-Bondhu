import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../database/app_database.dart';
import '../../database/database_tables.dart';

/// Simple backup/restore utility that exports all tables to JSON.
///
/// V1 ships without cloud backup (spec #31, V2). We provide:
///   - **exportToFile** — write a single JSON snapshot to the documents
///     directory and return the [File] so the user can share it via the
///     platform share sheet.
///   - **restoreFromFile** — wipe existing rows and re-insert the rows
///     inside a backup JSON file. Wrapped in a transaction so a failed
///     restore leaves the DB untouched.
class BackupService {
  BackupService(this._db);
  final AppDatabase _db;

  /// Tables to export. The order also drives restore order so that foreign
  /// keys (parent rows) are inserted before their children.
  static const List<String> _tables = [
    Tables.semesters,
    Tables.subjects,
    Tables.topics,
    Tables.syllabusItems,
    Tables.assignments,
    Tables.exams,
    Tables.attendance,
    Tables.studySessions,
    Tables.revisionItems,
    Tables.notes,
    Tables.expenses,
    Tables.goals,
  ];

  Future<File> exportToFile() async {
    final db = await _db.database;
    final data = <String, List<Map<String, Object?>>>{};
    for (final t in _tables) {
      data[t] = List<Map<String, Object?>>.from(await db.query(t));
    }
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File(p.join(dir.path, 'study_bondhu_backup_$ts.json'));
    await file.writeAsString(jsonEncode({
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'data': data,
    }));
    return file;
  }

  /// Restore the database from a backup file. Wipes existing rows first
  /// (in reverse-foreign-key order) and re-inserts everything in a single
  /// transaction. Throws [FormatException] if the JSON doesn't look like a
  /// StudyBondhu export.
  Future<void> restoreFromFile(File file) async {
    final raw = await file.readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is! Map ||
        decoded['data'] is! Map ||
        decoded['version'] is! int) {
      throw const FormatException('Not a StudyBondhu backup file');
    }
    final data = Map<String, dynamic>.from(decoded['data'] as Map);
    final db = await _db.database;

    await db.transaction((txn) async {
      // Wipe in reverse so FK cascades don't fire mid-restore.
      for (final t in _tables.reversed) {
        await txn.delete(t);
      }
      for (final t in _tables) {
        final rows = data[t];
        if (rows is! List) continue;
        for (final row in rows) {
          if (row is! Map) continue;
          await txn.insert(
            t,
            Map<String, Object?>.from(row),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }
}