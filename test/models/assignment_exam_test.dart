import 'package:flutter_test/flutter_test.dart';
import 'package:study_bondhu/features/assignments/models/assignment.dart';
import 'package:study_bondhu/features/exams/models/exam.dart';

void main() {
  group('Assignment model', () {
    test('round-trips through toMap/fromMap', () {
      final now = DateTime.now();
      final a = Assignment(
        id: 42,
        subjectId: 1,
        topicId: 2,
        title: 'Math HW 5',
        description: 'Complete questions 1 to 10',
        dueDate: now.add(const Duration(days: 3)),
        priority: AssignmentPriority.high,
        status: AssignmentStatus.pending,
        type: AssignmentType.homework,
        estimatedMinutes: 45,
        createdAt: now,
      );

      final map = a.toMap();
      final parsed = Assignment.fromMap(map);

      expect(parsed.id, a.id);
      expect(parsed.subjectId, a.subjectId);
      expect(parsed.topicId, a.topicId);
      expect(parsed.title, a.title);
      expect(parsed.description, a.description);
      expect(parsed.priority, a.priority);
      expect(parsed.status, a.status);
      expect(parsed.type, a.type);
      expect(parsed.estimatedMinutes, a.estimatedMinutes);
    });

    test('copyWith updates specified fields', () {
      final a = Assignment(
        id: 1,
        title: 'Draft',
        createdAt: DateTime.now(),
      );

      final updated = a.copyWith(
        title: 'Final Draft',
        status: AssignmentStatus.completed,
      );

      expect(updated.id, 1);
      expect(updated.title, 'Final Draft');
      expect(updated.status, AssignmentStatus.completed);
    });
  });

  group('Exam model', () {
    test('round-trips through toMap/fromMap', () {
      final now = DateTime.now();
      final e = Exam(
        id: 7,
        subjectId: 3,
        title: 'Biology Midterm',
        examDate: now.add(const Duration(days: 10)),
        type: ExamType.midterm,
        syllabus: 'Chapters 1-4',
        notes: 'Bring calculator',
        time: '10:00 AM',
        location: 'Room 302',
        createdAt: now,
      );

      final map = e.toMap();
      final parsed = Exam.fromMap(map);

      expect(parsed.id, e.id);
      expect(parsed.subjectId, e.subjectId);
      expect(parsed.title, e.title);
      expect(parsed.type, e.type);
      expect(parsed.syllabus, e.syllabus);
      expect(parsed.notes, e.notes);
      expect(parsed.time, e.time);
      expect(parsed.location, e.location);
    });

    test('copyWith updates specified fields', () {
      final now = DateTime.now();
      final e = Exam(
        id: 7,
        title: 'Midterm',
        examDate: now,
        createdAt: now,
      );

      final updated = e.copyWith(
        title: 'Midterm (Postponed)',
        location: 'Hall B',
      );

      expect(updated.id, 7);
      expect(updated.title, 'Midterm (Postponed)');
      expect(updated.location, 'Hall B');
    });
  });
}
