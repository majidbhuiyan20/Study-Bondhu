import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/utils/date_utils.dart';
import '../../subjects/models/subject.dart';
import '../../subjects/models/topic.dart';
import '../models/revision_item.dart';

class RevisionState {
  final bool isLoading;
  final List<RevisionItem> items;
  final String? errorMessage;
  final int? pendingMutationId; // id currently being mutated (UI should disable)

  const RevisionState({
    this.isLoading = false,
    this.items = const [],
    this.errorMessage,
    this.pendingMutationId,
  });

  RevisionState copyWith({
    bool? isLoading,
    List<RevisionItem>? items,
    Object? errorMessage = _sentinel,
    Object? pendingMutationId = _sentinel,
  }) =>
      RevisionState(
        isLoading: isLoading ?? this.isLoading,
        items: items ?? this.items,
        errorMessage: identical(errorMessage, _sentinel)
            ? this.errorMessage
            : errorMessage as String?,
        pendingMutationId: identical(pendingMutationId, _sentinel)
            ? this.pendingMutationId
            : pendingMutationId as int?,
      );

  static const Object _sentinel = Object();
}

class RevisionViewModel extends StateNotifier<RevisionState> {
  RevisionViewModel(this._ref) : super(const RevisionState());
  final Ref _ref;

  static const Set<int> _allowedRatings = {1, 3, 5};

  Future<void> bootstrap() async {
    await load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final items =
          await _ref.read(revisionRepositoryProvider).getPending();
      state = RevisionState(isLoading: false, items: items);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load revisions: $e',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
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
  /// strong). Spaced-repetition rules:
  ///   - Strong (5) → interval × 2, floor 1, cap 30, topic → mastered.
  ///   - Okay   (3) → interval × 1.5 (rounded), floor 2, cap 30, topic unchanged.
  ///   - Weak   (1) → interval ÷ 2, floor 1, cap 30, topic → weak.
  ///
  /// Returns `true` on success, `false` if the revision was already
  /// completed (idempotent no-op).
  Future<bool> markCompletedWithRating(
    RevisionItem r,
    int rating,
  ) async {
    if (r.id == null) {
      _fail('RevisionItem.id is null — cannot mark completed.');
      return false;
    }
    if (r.status != RevisionStatus.pending) {
      // Idempotent: tapping done on an already-completed revision is
      // a no-op rather than a crash.
      return false;
    }
    if (!_allowedRatings.contains(rating)) {
      _fail('Rating must be one of 1, 3, or 5. Got: $rating');
      return false;
    }

    state = state.copyWith(pendingMutationId: r.id);
    try {
      final newInterval = _nextInterval(r.intervalDays, rating);
      final nextScheduled = AppDateUtils.morningOf(
        DateTime.now().add(Duration(days: newInterval)),
      );

      final repo = _ref.read(revisionRepositoryProvider);
      final subjectsRepo = _ref.read(subjectsRepositoryProvider);

      // 1) Atomic transaction: flip current to completed+rating, then
      //    upsert the next pending row for the same topic.
      final flipped = await repo.markCompletedWithFollowup(
        currentId: r.id!,
        rating: rating,
        next: RevisionItem(
          subjectId: r.subjectId,
          topicId: r.topicId,
          scheduledDate: nextScheduled,
          intervalDays: newInterval,
          status: RevisionStatus.pending,
          createdAt: DateTime.now(),
        ),
      );

      if (!flipped) {
        // Already completed by a concurrent tap. Refresh state and exit.
        await load();
        return false;
      }

      // 2) Best-effort topic status update. Outside the critical
      //    revision transaction so a topic-update failure doesn't roll
      //    back the user's "I just did this revision" event.
      if (r.topicId != null) {
        final topic = await subjectsRepo.getTopicById(r.topicId!);
        if (topic != null) {
          final newStatus = _nextTopicStatus(topic.status, rating);
          await subjectsRepo.updateTopic(
            topic.copyWith(
              status: newStatus,
              confidence: rating,
              isCompleted: rating == 5 ? true : topic.isCompleted,
            ),
          );
        }
      }

      state = state.copyWith(
        pendingMutationId: null,
        errorMessage: null,
      );
      await load();
      return true;
    } catch (e) {
      // Stack trace intentionally dropped; surfaces the error message
      // to the UI but does not log to console in release.
      state = state.copyWith(
        pendingMutationId: null,
        errorMessage: 'Failed to mark revision: $e',
      );
      await load();
      return false;
    }
  }

  void _fail(String message) {
    state = state.copyWith(errorMessage: message);
  }

  /// Pure helper exposed for unit testing.
  static int nextIntervalFor(int current, int rating) =>
      _nextInterval(current, rating);

  static int _nextInterval(int current, int rating) {
    switch (rating) {
      case 1: // weak — halve, floor 1, cap 30
        return (current ~/ 2).clamp(1, 30);
      case 3: // okay — ×1.5 rounded, floor 2, cap 30
        return (current * 1.5).round().clamp(2, 30);
      case 5: // strong — double, floor 1, cap 30
        return (current * 2).clamp(1, 30);
      default:
        throw ArgumentError.value(rating, 'rating', 'must be 1, 3, or 5');
    }
  }

  static TopicStatus nextTopicStatusFor(TopicStatus current, int rating) =>
      _nextTopicStatus(current, rating);

  static TopicStatus _nextTopicStatus(TopicStatus current, int rating) {
    switch (rating) {
      case 1:
        return TopicStatus.weak;
      case 5:
        return TopicStatus.mastered;
      case 3:
        return current; // okay: leave as-is
      default:
        throw ArgumentError.value(rating, 'rating', 'must be 1, 3, or 5');
    }
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

/// Cached lookup of subjects referenced by the current pending revisions.
/// Used by the revision view to render rows in O(1) instead of scanning
/// the subjects table per row.
final pendingRevisionSubjectsProvider =
    FutureProvider<Map<int, Subject>>((ref) async {
  final pending = ref.watch(pendingRevisionProvider);
  final ids = pending
      .map((r) => r.subjectId)
      .whereType<int>()
      .toSet()
      .toList();
  if (ids.isEmpty) return const {};
  return ref
      .read(subjectsRepositoryProvider)
      .getSubjectsByIds(ids);
});

/// Cached lookup of topics referenced by the current pending revisions.
final pendingRevisionTopicsProvider =
    FutureProvider<Map<int, Topic>>((ref) async {
  final pending = ref.watch(pendingRevisionProvider);
  final ids = pending
      .map((r) => r.topicId)
      .whereType<int>()
      .toSet()
      .toList();
  if (ids.isEmpty) return const {};
  return ref.read(subjectsRepositoryProvider).getTopicsByIds(ids);
});
