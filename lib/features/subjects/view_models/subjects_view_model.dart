import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../profile/view_models/profile_view_model.dart';
import '../models/semester.dart';
import '../models/subject.dart';
import '../models/syllabus_item.dart';
import '../models/topic.dart';

class SubjectsState {
  final bool isLoading;
  final List<Semester> semesters;
  final List<Subject> subjects;
  final Semester? activeSemester;

  const SubjectsState({
    this.isLoading = false,
    this.semesters = const [],
    this.subjects = const [],
    this.activeSemester,
  });

  SubjectsState copyWith({
    bool? isLoading,
    List<Semester>? semesters,
    List<Subject>? subjects,
    Semester? activeSemester,
  }) =>
      SubjectsState(
        isLoading: isLoading ?? this.isLoading,
        semesters: semesters ?? this.semesters,
        subjects: subjects ?? this.subjects,
        activeSemester: activeSemester ?? this.activeSemester,
      );
}

class SubjectsViewModel extends StateNotifier<SubjectsState> {
  SubjectsViewModel(this._ref) : super(const SubjectsState());

  final Ref _ref;

  /// Defer initial load until after first frame to avoid nested
  /// provider initialization. Call from view's initState.
  void bootstrap() {
    Future.microtask(load);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final repo = _ref.read(subjectsRepositoryProvider);
    final semesters = await repo.getSemesters();
    Semester? active;
    for (final s in semesters) {
      if (s.isActive) {
        active = s;
        break;
      }
    }
    active ??= semesters.isEmpty ? null : semesters.first;
    final subjects = await repo.getSubjects(semesterId: active?.id);
    state = SubjectsState(
      isLoading: false,
      semesters: semesters,
      subjects: subjects,
      activeSemester: active,
    );
  }

  Future<void> addSemester(Semester s) async {
    final profileId = s.profileId ?? _ref.read(profileViewModelProvider).active?.id;
    await _ref
        .read(subjectsRepositoryProvider)
        .addSemester(s.copyWith(profileId: profileId));
    await load();
  }

  Future<void> addSubject(Subject s) async {
    await _ref.read(subjectsRepositoryProvider).addSubject(s);
    await load();
  }

  Future<void> updateSubject(Subject s) async {
    await _ref.read(subjectsRepositoryProvider).updateSubject(s);
    await load();
  }

  Future<void> deleteSubject(int id) async {
    await _ref.read(subjectsRepositoryProvider).deleteSubject(id);
    await load();
  }

  Future<void> setActiveSemester(Semester s) async {
    if (s.id == null) return;
    await _ref.read(subjectsRepositoryProvider).setActiveSemester(s.id!);
    await load();
  }

  Future<void> addTopic(Topic t) async {
    await _ref.read(subjectsRepositoryProvider).addTopic(t);
  }

  Future<void> updateTopic(Topic t) async {
    await _ref.read(subjectsRepositoryProvider).updateTopic(t);
  }

  Future<void> deleteTopic(int id) async {
    await _ref.read(subjectsRepositoryProvider).deleteTopic(id);
  }

  Future<List<Topic>> getTopics(int subjectId) =>
      _ref.read(subjectsRepositoryProvider).getTopics(subjectId);

  Future<List<SyllabusItem>> getSyllabus(int subjectId) =>
      _ref.read(subjectsRepositoryProvider).getSyllabus(subjectId);

  Future<void> addSyllabus(SyllabusItem s) =>
      _ref.read(subjectsRepositoryProvider).addSyllabus(s);

  Future<void> toggleSyllabus(SyllabusItem s) =>
      _ref.read(subjectsRepositoryProvider).updateSyllabus(
            s.copyWith(
              isDone: !s.isDone,
              completedAt: !s.isDone ? DateTime.now() : null,
            ),
          );

  Future<void> renameSyllabus(SyllabusItem s, String newTitle) =>
      _ref.read(subjectsRepositoryProvider).updateSyllabus(
            s.copyWith(title: newTitle),
          );

  Future<void> reorderSyllabus(int subjectId, int oldIdx, int newIdx) async {
    final list = await getSyllabus(subjectId);
    if (oldIdx < 0 || oldIdx >= list.length) return;
    final item = list.removeAt(oldIdx);
    final insertAt = newIdx > oldIdx ? newIdx - 1 : newIdx;
    list.insert(insertAt.clamp(0, list.length), item);
    await _ref
        .read(subjectsRepositoryProvider)
        .replaceSyllabusForSubject(subjectId, list);
    await load();
  }

  Future<void> deleteSyllabus(int id) =>
      _ref.read(subjectsRepositoryProvider).deleteSyllabus(id);
}

final subjectsViewModelProvider =
    StateNotifierProvider<SubjectsViewModel, SubjectsState>(
  (ref) => SubjectsViewModel(ref),
);

// Stream provider for individual subject topics (rebuilds on demand)
final topicsForSubjectProvider =
    FutureProvider.family.autoDispose<List<Topic>, int>(
  (ref, subjectId) async {
    final repo = ref.watch(subjectsRepositoryProvider);
    return repo.getTopics(subjectId);
  },
);

final syllabusForSubjectProvider =
    FutureProvider.family.autoDispose<List<SyllabusItem>, int>(
  (ref, subjectId) async {
    final repo = ref.watch(subjectsRepositoryProvider);
    return repo.getSyllabus(subjectId);
  },
);
