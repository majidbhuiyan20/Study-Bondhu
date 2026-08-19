import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../models/routine.dart';

class RoutinesState {
  final bool isLoading;
  final List<Routine> routines;
  final List<Routine> todaysRoutines;
  const RoutinesState({
    this.isLoading = false,
    this.routines = const [],
    this.todaysRoutines = const [],
  });

  RoutinesState copyWith({
    bool? isLoading,
    List<Routine>? routines,
    List<Routine>? todaysRoutines,
  }) =>
      RoutinesState(
        isLoading: isLoading ?? this.isLoading,
        routines: routines ?? this.routines,
        todaysRoutines: todaysRoutines ?? this.todaysRoutines,
      );
}

class RoutinesViewModel extends StateNotifier<RoutinesState> {
  RoutinesViewModel(this._ref) : super(const RoutinesState());
  final Ref _ref;

  void bootstrap() {
    Future.microtask(load);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final repo = _ref.read(routinesRepositoryProvider);
    final all = await repo.getRoutines();
    final today = DateTime.now();
    final filtered = all
        .where((r) =>
            r.isActive && r.isOnDay(today) && !_doneToday(r.lastDone))
        .toList();
    state = RoutinesState(
      isLoading: false,
      routines: all,
      todaysRoutines: filtered,
    );
  }

  bool _doneToday(DateTime? last) {
    if (last == null) return false;
    return last.year == DateTime.now().year &&
        last.month == DateTime.now().month &&
        last.day == DateTime.now().day;
  }

  Future<void> addRoutine(Routine r) async {
    await _ref.read(routinesRepositoryProvider).addRoutine(r);
    await load();
  }

  Future<void> updateRoutine(Routine r) async {
    await _ref.read(routinesRepositoryProvider).updateRoutine(r);
    await load();
  }

  Future<void> deleteRoutine(int id) async {
    await _ref.read(routinesRepositoryProvider).deleteRoutine(id);
    await load();
  }

  Future<void> markDone(int id) async {
    await _ref.read(routinesRepositoryProvider).markDoneToday(id);
    await load();
  }
}

final routinesViewModelProvider =
    StateNotifierProvider<RoutinesViewModel, RoutinesState>(
  (ref) => RoutinesViewModel(ref),
);