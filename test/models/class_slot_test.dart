import 'package:flutter_test/flutter_test.dart';
import 'package:study_bondhu/features/timetable/models/class_slot.dart';

void main() {
  group('ClassSlot', () {
    test('startMinutes returns total minutes since midnight', () {
      final slot = ClassSlot(
        subjectId: 1,
        dayOfWeek: 1,
        startTime: '08:30',
        endTime: '09:30',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
      expect(slot.startMinutes, 8 * 60 + 30);
    });

    test('startMinutes returns 0 for malformed input', () {
      final slot = ClassSlot(
        subjectId: 1,
        dayOfWeek: 1,
        startTime: 'bogus',
        endTime: 'still bogus',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
      expect(slot.startMinutes, 0);
    });

    test('round-trips through toMap/fromMap', () {
      final created = DateTime.fromMillisecondsSinceEpoch(1_700_000_000_000);
      final original = ClassSlot(
        id: 11,
        subjectId: 3,
        dayOfWeek: 5,
        startTime: '10:00',
        endTime: '11:15',
        location: 'Room 204',
        createdAt: created,
      );
      final round = ClassSlot.fromMap(original.toMap());
      expect(round.id, 11);
      expect(round.subjectId, 3);
      expect(round.dayOfWeek, 5);
      expect(round.startTime, '10:00');
      expect(round.endTime, '11:15');
      expect(round.location, 'Room 204');
      expect(round.createdAt, created);
    });

    test('copyWith updates only the supplied field', () {
      final s = ClassSlot(
        id: 1,
        subjectId: 2,
        dayOfWeek: 3,
        startTime: '08:00',
        endTime: '09:00',
        location: 'A',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
      final u = s.copyWith(location: 'B', startTime: '10:00');
      expect(u.location, 'B');
      expect(u.startTime, '10:00');
      expect(u.subjectId, 2); // unchanged
      expect(u.dayOfWeek, 3); // unchanged
      expect(u.endTime, '09:00'); // unchanged
    });

    test('dayOfWeek 1=Mon..7=Sun (DateTime.weekday semantics)', () {
      // This documents the convention. No runtime check beyond sanity.
      for (var d = 1; d <= 7; d++) {
        final s = ClassSlot(
          subjectId: 1,
          dayOfWeek: d,
          startTime: '00:00',
          endTime: '00:00',
          createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        );
        expect(s.dayOfWeek, d);
      }
    });
  });
}