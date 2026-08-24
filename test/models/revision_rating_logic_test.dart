import 'package:flutter_test/flutter_test.dart';
import 'package:study_bondhu/features/revision/models/revision_item.dart';
import 'package:study_bondhu/features/revision/view_models/revision_view_model.dart';
import 'package:study_bondhu/features/subjects/models/topic.dart';

void main() {
  group('RevisionViewModel.nextIntervalFor', () {
    test('Weak (1) halves current and floors at 1', () {
      expect(RevisionViewModel.nextIntervalFor(1, 1), 1);
      expect(RevisionViewModel.nextIntervalFor(3, 1), 1);
      expect(RevisionViewModel.nextIntervalFor(4, 1), 2);
      expect(RevisionViewModel.nextIntervalFor(10, 1), 5);
    });

    test('Weak (1) caps at 30', () {
      // 30 stays 30 (already capped) — but actually 30 ~/ 2 = 15.
      expect(RevisionViewModel.nextIntervalFor(30, 1), 15);
    });

    test('Okay (3) multiplies by 1.5 and rounds', () {
      expect(RevisionViewModel.nextIntervalFor(1, 3), 2); // round 1.5 → 2
      expect(RevisionViewModel.nextIntervalFor(2, 3), 3);
      expect(RevisionViewModel.nextIntervalFor(4, 3), 6);
      expect(RevisionViewModel.nextIntervalFor(10, 3), 15);
      expect(RevisionViewModel.nextIntervalFor(13, 3), 20); // round 19.5 → 20
    });

    test('Okay (3) floors at 2', () {
      // 1 → 1.5 → rounds to 2 (the floor).
      expect(RevisionViewModel.nextIntervalFor(1, 3), 2);
    });

    test('Okay (3) caps at 30', () {
      // 25 × 1.5 = 37.5 → round 38 → cap 30.
      expect(RevisionViewModel.nextIntervalFor(25, 3), 30);
      expect(RevisionViewModel.nextIntervalFor(20, 3), 30); // 30 exactly
    });

    test('Strong (5) doubles and floors at 1', () {
      expect(RevisionViewModel.nextIntervalFor(1, 5), 2);
      expect(RevisionViewModel.nextIntervalFor(3, 5), 6);
      expect(RevisionViewModel.nextIntervalFor(10, 5), 20);
    });

    test('Strong (5) caps at 30 and does not grow beyond', () {
      expect(RevisionViewModel.nextIntervalFor(20, 5), 30);
      expect(RevisionViewModel.nextIntervalFor(30, 5), 30); // no growth
    });

    test('Invalid rating throws', () {
      expect(() => RevisionViewModel.nextIntervalFor(5, 0),
          throwsArgumentError);
      expect(() => RevisionViewModel.nextIntervalFor(5, 2),
          throwsArgumentError);
      expect(() => RevisionViewModel.nextIntervalFor(5, 4),
          throwsArgumentError);
      expect(() => RevisionViewModel.nextIntervalFor(5, 7),
          throwsArgumentError);
    });
  });

  group('RevisionViewModel.nextTopicStatusFor', () {
    test('Weak (1) always returns weak', () {
      expect(
        RevisionViewModel.nextTopicStatusFor(TopicStatus.learning, 1),
        TopicStatus.weak,
      );
      expect(
        RevisionViewModel.nextTopicStatusFor(TopicStatus.mastered, 1),
        TopicStatus.weak,
      );
      expect(
        RevisionViewModel.nextTopicStatusFor(TopicStatus.notStarted, 1),
        TopicStatus.weak,
      );
    });

    test('Strong (5) always returns mastered', () {
      expect(
        RevisionViewModel.nextTopicStatusFor(TopicStatus.learning, 5),
        TopicStatus.mastered,
      );
      expect(
        RevisionViewModel.nextTopicStatusFor(TopicStatus.weak, 5),
        TopicStatus.mastered,
      );
    });

    test('Okay (3) leaves status unchanged', () {
      expect(
        RevisionViewModel.nextTopicStatusFor(TopicStatus.weak, 3),
        TopicStatus.weak,
      );
      expect(
        RevisionViewModel.nextTopicStatusFor(TopicStatus.learning, 3),
        TopicStatus.learning,
      );
      expect(
        RevisionViewModel.nextTopicStatusFor(TopicStatus.notStarted, 3),
        TopicStatus.notStarted,
      );
    });

    test('Invalid rating throws', () {
      expect(
        () => RevisionViewModel.nextTopicStatusFor(TopicStatus.learning, 0),
        throwsArgumentError,
      );
    });
  });

  group('RevisionItem rating parse', () {
    test('round-trips rating 1/3/5', () {
      final now = DateTime.fromMillisecondsSinceEpoch(0);
      for (final r in [1, 3, 5]) {
        final original = RevisionItem(
          scheduledDate: now,
          rating: r,
          createdAt: now,
        );
        final round = RevisionItem.fromMap(original.toMap());
        expect(round.rating, r);
      }
    });

    test('clamps malformed rating to null', () {
      final now = DateTime.fromMillisecondsSinceEpoch(0);
      final r = RevisionItem.fromMap({
        'id': 1,
        'subject_id': null,
        'topic_id': null,
        'scheduled_date': now.millisecondsSinceEpoch,
        'status': 'pending',
        'interval_days': 1,
        'rating': 7, // invalid
        'created_at': now.millisecondsSinceEpoch,
      });
      expect(r.rating, isNull);
    });

    test('handles missing rating', () {
      final now = DateTime.fromMillisecondsSinceEpoch(0);
      final r = RevisionItem.fromMap({
        'id': 1,
        'subject_id': null,
        'topic_id': null,
        'scheduled_date': now.millisecondsSinceEpoch,
        'status': 'pending',
        'interval_days': 1,
        'created_at': now.millisecondsSinceEpoch,
      });
      expect(r.rating, isNull);
    });
  });
}