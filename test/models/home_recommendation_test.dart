import 'package:flutter_test/flutter_test.dart';
import 'package:study_bondhu/features/exams/models/exam.dart';
import 'package:study_bondhu/features/home/view_models/home_view_model.dart';
import 'package:study_bondhu/features/subjects/models/subject.dart';
import 'package:study_bondhu/features/subjects/models/topic.dart';

void main() {
  final now = DateTime.now();
  final subjectA = Subject(id: 1, name: 'Physics', color: '#4F46E5', createdAt: now);
  final subjectB = Subject(id: 2, name: 'Chemistry', color: '#10B981', createdAt: now);
  final subjects = <Subject>[subjectA, subjectB];

  group('HomeViewModel.computeRecommendation', () {
    test('returns null when subjects is empty', () {
      final rec = HomeViewModel.computeRecommendation(
        subjects: [],
        upcomingExams: [],
        subjectSeconds: {},
        pendingRevisions: [],
        weakTopics: [],
      );
      expect(rec, isNull);
    });

    test('prioritizes exam within 14 days over weak topics and study time', () {
      final now = DateTime.now();
      final nearExam = Exam(
        id: 10,
        subjectId: 1,
        title: 'Physics Midterm',
        examDate: now.add(const Duration(days: 5)),
        type: ExamType.midterm,
        createdAt: now,
      );
      final weakTopic = Topic(
        id: 101,
        subjectId: 2,
        name: 'Organic Reactions',
        confidence: 1,
        createdAt: now,
      );

      final rec = HomeViewModel.computeRecommendation(
        subjects: subjects,
        upcomingExams: [nearExam],
        subjectSeconds: {1: 3600, 2: 0},
        pendingRevisions: [],
        weakTopics: [weakTopic],
      );

      expect(rec, isNotNull);
      expect(rec!.subject.id, 1);
      expect(rec.reason, contains('Physics Midterm'));
    });

    test('ignores exams beyond 14 days and falls back to weak topic', () {
      final now = DateTime.now();
      final farExam = Exam(
        id: 20,
        subjectId: 1,
        title: 'Physics Final',
        examDate: now.add(const Duration(days: 45)),
        type: ExamType.finalExam,
        createdAt: now,
      );
      final weakTopic = Topic(
        id: 101,
        subjectId: 2,
        name: 'Organic Reactions',
        confidence: 1,
        createdAt: now,
      );

      final rec = HomeViewModel.computeRecommendation(
        subjects: subjects,
        upcomingExams: [farExam],
        subjectSeconds: {1: 3600, 2: 3600},
        pendingRevisions: [],
        weakTopics: [weakTopic],
      );

      expect(rec, isNotNull);
      expect(rec!.subject.id, 2);
      expect(rec.reason, contains('Organic Reactions'));
    });

    test('falls back to lowest study time when no near exams or weak topics', () {
      final rec = HomeViewModel.computeRecommendation(
        subjects: subjects,
        upcomingExams: [],
        subjectSeconds: {1: 3600, 2: 600},
        pendingRevisions: [],
        weakTopics: [],
      );

      expect(rec, isNotNull);
      expect(rec!.subject.id, 2);
      expect(rec.reason, contains('Lowest study time'));
    });
  });
}
