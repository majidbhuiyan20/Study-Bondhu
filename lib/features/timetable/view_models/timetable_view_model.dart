import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../models/class_slot.dart';

class TimetableState {
  final bool isLoading;
  final List<ClassSlot> slots;
  const TimetableState({this.isLoading = false, this.slots = const []});

  TimetableState copyWith({bool? isLoading, List<ClassSlot>? slots}) =>
      TimetableState(
        isLoading: isLoading ?? this.isLoading,
        slots: slots ?? this.slots,
      );
}

class TimetableViewModel extends StateNotifier<TimetableState> {
  TimetableViewModel(this._ref) : super(const TimetableState());
  final Ref _ref;

  void bootstrap() => Future.microtask(load);

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final list = await _ref.read(timetableRepositoryProvider).getSlots();
    state = state.copyWith(isLoading: false, slots: list);
  }

  Future<void> addSlot(ClassSlot s) async {
    await _ref.read(timetableRepositoryProvider).addSlot(s);
    await load();
  }

  Future<void> updateSlot(ClassSlot s) async {
    await _ref.read(timetableRepositoryProvider).updateSlot(s);
    await load();
  }

  Future<void> deleteSlot(int id) async {
    await _ref.read(timetableRepositoryProvider).deleteSlot(id);
    await load();
  }
}

final timetableViewModelProvider =
    StateNotifierProvider<TimetableViewModel, TimetableState>(
  (ref) => TimetableViewModel(ref),
);
