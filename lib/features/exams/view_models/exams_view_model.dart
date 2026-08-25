import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../models/exam.dart';

class ExamsState {
  final bool isLoading;
  final List<Exam> exams;
  const ExamsState({this.isLoading = false, this.exams = const []});
  ExamsState copyWith({bool? isLoading, List<Exam>? exams}) => ExamsState(
        isLoading: isLoading ?? this.isLoading,
        exams: exams ?? this.exams,
      );
}

class ExamsViewModel extends StateNotifier<ExamsState> {
  ExamsViewModel(this._ref) : super(const ExamsState());
  final Ref _ref;

  void bootstrap() {
    Future.microtask(load);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final list = await _ref.read(examsRepositoryProvider).getExams();
    state = ExamsState(isLoading: false, exams: list);
  }

  Future<void> addExam(Exam e) async {
    await _ref.read(examsRepositoryProvider).addExam(e);
    await load();
  }

  Future<void> updateExam(Exam e) async {
    await _ref.read(examsRepositoryProvider).updateExam(e);
    await load();
  }

  Future<void> deleteExam(int id) async {
    await _ref.read(examsRepositoryProvider).deleteExam(id);
    await load();
  }
}

final examsViewModelProvider =
    StateNotifierProvider<ExamsViewModel, ExamsState>(
  (ref) => ExamsViewModel(ref),
);

final upcomingExamsProvider = Provider<List<Exam>>((ref) {
  final all = ref.watch(examsViewModelProvider).exams;
  final now = DateTime.now();
  return all
      .where((e) =>
          !e.examDate.isBefore(DateTime(now.year, now.month, now.day)))
      .toList()
    ..sort((a, b) => a.examDate.compareTo(b.examDate));
});