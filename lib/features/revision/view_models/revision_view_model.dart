import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../subjects/models/topic.dart';
import '../models/revision_item.dart';

class RevisionState {
  final bool isLoading;
  final List<RevisionItem> items;
  const RevisionState({this.isLoading = false, this.items = const []});
  RevisionState copyWith({bool? isLoading, List<RevisionItem>? items}) =>
      RevisionState(
        isLoading: isLoading ?? this.isLoading,
        items: items ?? this.items,
      );
}

class RevisionViewModel extends StateNotifier<RevisionState> {
  RevisionViewModel(this._ref) : super(const RevisionState());
  final Ref _ref;

  void bootstrap() {
    Future.microtask(load);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final items =
        await _ref.read(revisionRepositoryProvider).getAll();
    state = RevisionState(isLoading: false, items: items);
  }

  Future<void> addRevision(RevisionItem r) async {
    await _ref.read(revisionRepositoryProvider).addRevision(r);
    await load();
  }

  Future<void> updateRevision(RevisionItem r) async {
    await _ref.read(revisionRepositoryProvider).updateRevision(r);
    await load();
  }

  Future<void> deleteRevision(int id) async {
    await _ref.read(revisionRepositoryProvider).deleteRevision(id);
    await load();
  }

  /// Marks a revision completed with a 3-state rating (1 weak, 3 okay, 5
  /// strong). Spec 10:
  ///   - Strong → interval doubles (capped at 30), topic.status = mastered.
  ///   - Okay   → interval stays at 3, topic.status unchanged.
  ///   - Weak   → interval halves (floor 1), topic.status = weak.
  Future<void> markCompletedWithRating(
    RevisionItem r,
    int rating,
  ) async {
    // 1) Flip status to completed.
    await _ref.read(revisionRepositoryProvider).updateRevision(
          r.copyWith(status: RevisionStatus.completed),
        );

    // 2) Update Topic.status if we have a topic.
    if (r.topicId != null) {
      final allTopics =
          await _ref.read(subjectsRepositoryProvider).getAllTopics();
      Topic? found;
      for (final t in allTopics) {
        if (t.id == r.topicId) {
          found = t;
          break;
        }
      }
      if (found != null) {
        final newStatus = switch (rating) {
          1 => TopicStatus.weak,
          5 => TopicStatus.mastered,
          _ => found.status, // okay: leave as-is
        };
        await _ref.read(subjectsRepositoryProvider).updateTopic(
              found.copyWith(
                status: newStatus,
                confidence: rating,
                isCompleted: rating == 5 ? true : found.isCompleted,
              ),
            );
      }
    }

    // 3) Schedule the next revision with adjusted interval.
    final newInterval = switch (rating) {
      1 => (r.intervalDays ~/ 2).clamp(1, 30),
      5 => (r.intervalDays * 2).clamp(1, 30),
      _ => r.intervalDays,
    };
    await _ref.read(revisionRepositoryProvider).addRevision(
          RevisionItem(
            subjectId: r.subjectId,
            topicId: r.topicId,
            scheduledDate:
                DateTime.now().add(Duration(days: newInterval)),
            intervalDays: newInterval,
            status: RevisionStatus.pending,
            createdAt: DateTime.now(),
          ),
        );
    await load();
  }
}

final revisionViewModelProvider =
    StateNotifierProvider<RevisionViewModel, RevisionState>(
  (ref) => RevisionViewModel(ref),
);

final pendingRevisionProvider = Provider<List<RevisionItem>>((ref) {
  final all = ref.watch(revisionViewModelProvider).items;
  return all.where((r) => r.status == RevisionStatus.pending).toList()
    ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
});