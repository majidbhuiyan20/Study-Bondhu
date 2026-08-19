import 'package:flutter_test/flutter_test.dart';
import 'package:study_bondhu/features/subjects/models/subject.dart';

void main() {
  group('Subject.fromMap', () {
    test('round-trips all fields through toMap', () {
      final created = DateTime.fromMillisecondsSinceEpoch(1_700_000_000_000);
      final original = Subject(
        id: 7,
        name: 'Bangla',
        code: 'BAN101',
        credit: 3.0,
        teacher: 'Ms. Akter',
        color: '#FF6B6B',
        semesterId: 2,
        targetAttendance: 80,
        createdAt: created,
      );
      final round = Subject.fromMap(original.toMap());
      expect(round.id, 7);
      expect(round.name, 'Bangla');
      expect(round.code, 'BAN101');
      expect(round.credit, 3.0);
      expect(round.teacher, 'Ms. Akter');
      expect(round.color, '#FF6B6B');
      expect(round.semesterId, 2);
      expect(round.targetAttendance, 80);
      expect(round.createdAt, created);
    });

    test('defaults targetAttendance to 75 when missing', () {
      final s = Subject.fromMap({
        'id': 1,
        'name': 'Math',
        'created_at': 0,
      });
      expect(s.targetAttendance, 75);
    });

    test('defaults color to #4F46E5 when missing', () {
      final s = Subject.fromMap({
        'id': 1,
        'name': 'Math',
        'created_at': 0,
      });
      expect(s.color, '#4F46E5');
    });

    test('toMap omits id when null', () {
      final s = Subject(
        name: 'X',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
      expect(s.toMap().containsKey('id'), isFalse);
    });

    test('copyWith preserves untouched fields', () {
      final s = Subject(
        id: 1,
        name: 'A',
        color: '#000000',
        targetAttendance: 60,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
      final updated = s.copyWith(name: 'B');
      expect(updated.name, 'B');
      expect(updated.color, '#000000');
      expect(updated.targetAttendance, 60);
      expect(updated.id, 1);
    });
  });
}