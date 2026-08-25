import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../models/assignment.dart';
import '../models/assignment_subtask.dart';

class AssignmentsState {
  final bool isLoading;
  final List<Assignment> assignments;
  const AssignmentsState({
    this.isLoading = false,
    this.assignments = const [],
  });

  AssignmentsState copyWith({
    bool? isLoading,
    List<Assignment>? assignments,
  }) =>
      AssignmentsState(
        isLoading: isLoading ?? this.isLoading,
        assignments: assignments ?? this.assignments,
      );
}

class AssignmentsViewModel extends StateNotifier<AssignmentsState> {
  AssignmentsViewModel(this._ref) : super(const AssignmentsState());
  final Ref _ref;

  void bootstrap() {
    Future.microtask(load);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final list = await _ref.read(assignmentsRepositoryProvider).getAssignments();
    state = AssignmentsState(isLoading: false, assignments: list);
  }

  Future<void> addAssignment(Assignment a) async {
    await _ref.read(assignmentsRepositoryProvider).addAssignment(a);
    await load();
  }

  Future<void> updateAssignment(Assignment a) async {
    await _ref.read(assignmentsRepositoryProvider).updateAssignment(a);
    await load();
  }

  Future<void> toggleComplete(Assignment a) async {
    await _ref.read(assignmentsRepositoryProvider).toggleComplete(a);
    await load();
  }

  Future<void> deleteAssignment(int id) async {
    await _ref.read(assignmentsRepositoryProvider).deleteAssignment(id);
    await load();
  }

  // -------------------------------------------------------------------
  // Subtasks (spec 06)
  // -------------------------------------------------------------------

  Future<void> addSubtask(AssignmentSubtask s) async {
    await _ref.read(assignmentsRepositoryProvider).addSubtask(s);
    _ref.invalidate(subtasksProvider(s.assignmentId));
    _ref.invalidate(subtaskProgressProvider);
  }

  Future<void> toggleSubtask(AssignmentSubtask s) async {
    await _ref.read(assignmentsRepositoryProvider).updateSubtask(
          s.copyWith(isDone: !s.isDone),
        );
    _ref.invalidate(subtasksProvider(s.assignmentId));
    _ref.invalidate(subtaskProgressProvider);
  }

  Future<void> deleteSubtask(int assignmentId, int subtaskId) async {
    await _ref
        .read(assignmentsRepositoryProvider)
        .deleteSubtask(subtaskId);
    _ref.invalidate(subtasksProvider(assignmentId));
    _ref.invalidate(subtaskProgressProvider);
  }
}

final assignmentsViewModelProvider =
    StateNotifierProvider<AssignmentsViewModel, AssignmentsState>(
  (ref) => AssignmentsViewModel(ref),
);

final todayAssignmentsProvider = Provider<List<Assignment>>((ref) {
  final all = ref.watch(assignmentsViewModelProvider).assignments;
  return all.where((a) {
    if (a.dueDate == null) return false;
    return du.AppDateUtils.isSameDay(a.dueDate!, DateTime.now());
  }).toList();
});

final upcomingAssignmentsProvider = Provider<List<Assignment>>((ref) {
  final all = ref.watch(assignmentsViewModelProvider).assignments;
  final now = DateTime.now();
  return all
      .where((a) =>
          a.status == AssignmentStatus.pending &&
          a.dueDate != null &&
          a.dueDate!.isAfter(now))
      .toList()
    ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
});

/// Subtasks of a single assignment (spec 06).
final subtasksProvider =
    FutureProvider.family.autoDispose<List<AssignmentSubtask>, int>(
  (ref, assignmentId) async {
    return ref
        .watch(assignmentsRepositoryProvider)
        .getSubtasks(assignmentId);
  },
);

/// Map of assignmentId -> progress (0..1) for all assignments that have
/// subtasks. Listens to [assignmentsViewModelProvider] so adding/removing
/// assignments triggers a refresh.
final subtaskProgressProvider =
    FutureProvider.autoDispose<Map<int, double>>((ref) async {
  final all = ref.watch(assignmentsViewModelProvider).assignments;
  final ids = all
      .where((a) => a.id != null)
      .map((a) => a.id!)
      .toList(growable: false);
  return ref
      .watch(assignmentsRepositoryProvider)
      .progressForAssignments(ids);
});

