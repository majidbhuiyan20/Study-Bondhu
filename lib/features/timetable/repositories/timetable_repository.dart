import '../../../database/app_database.dart';
import '../../../database/database_tables.dart';
import '../models/class_slot.dart';

class TimetableRepository {
  TimetableRepository(this._db);
  final AppDatabase _db;

  Future<List<ClassSlot>> getSlots() async {
    final db = await _db.database;
    final rows = await db.query(
      Tables.timetable,
      orderBy: '${Columns.classDayOfWeek} ASC, ${Columns.classStartTime} ASC',
    );
    return rows.map(ClassSlot.fromMap).toList();
  }

  Future<int> addSlot(ClassSlot slot) async {
    final db = await _db.database;
    return db.insert(Tables.timetable, slot.toMap());
  }

  Future<void> updateSlot(ClassSlot slot) async {
    final db = await _db.database;
    await db.update(
      Tables.timetable,
      slot.toMap(),
      where: '${Columns.id} = ?',
      whereArgs: [slot.id],
    );
  }

  Future<void> deleteSlot(int id) async {
    final db = await _db.database;
    await db.delete(
      Tables.timetable,
      where: '${Columns.id} = ?',
      whereArgs: [id],
    );
  }

  /// Next slot occurring today or later, considering wall-clock time.
  ClassSlot? nextUpcoming(List<ClassSlot> slots) {
    final now = DateTime.now();
    int today = now.weekday;
    int nowMin = now.hour * 60 + now.minute;
    final candidates = <({int dayOffset, int startMin, ClassSlot slot})>[];
    for (final s in slots) {
      int offset = (s.dayOfWeek - today + 7) % 7;
      if (offset == 0 && s.startMinutes <= nowMin) continue;
      candidates.add((dayOffset: offset, startMin: s.startMinutes, slot: s));
    }
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      final c = a.dayOffset.compareTo(b.dayOffset);
      return c != 0 ? c : a.startMin.compareTo(b.startMin);
    });
    return candidates.first.slot;
  }
}