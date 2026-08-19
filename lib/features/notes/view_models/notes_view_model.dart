import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../models/note.dart';

class NotesState {
  final bool isLoading;
  final List<Note> notes;
  const NotesState({this.isLoading = false, this.notes = const []});
  NotesState copyWith({bool? isLoading, List<Note>? notes}) => NotesState(
        isLoading: isLoading ?? this.isLoading,
        notes: notes ?? this.notes,
      );
}

class NotesViewModel extends StateNotifier<NotesState> {
  NotesViewModel(this._ref) : super(const NotesState());
  final Ref _ref;

  void bootstrap() {
    Future.microtask(load);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final list = await _ref.read(notesRepositoryProvider).getNotes();
    state = NotesState(isLoading: false, notes: list);
  }

  Future<int> addNote(Note n) async {
    final id = await _ref.read(notesRepositoryProvider).addNote(n);
    await load();
    return id;
  }

  Future<void> updateNote(Note n) async {
    await _ref.read(notesRepositoryProvider).updateNote(n);
    await load();
  }

  Future<void> deleteNote(int id) async {
    await _ref.read(notesRepositoryProvider).deleteNote(id);
    await load();
  }

  Future<void> togglePin(Note n) async {
    if (n.id == null) return;
    await _ref.read(notesRepositoryProvider).updateNote(
          n.copyWith(isPinned: !n.isPinned, updatedAt: DateTime.now()),
        );
    await load();
  }
}

final notesViewModelProvider =
    StateNotifierProvider<NotesViewModel, NotesState>(
  (ref) => NotesViewModel(ref),
);