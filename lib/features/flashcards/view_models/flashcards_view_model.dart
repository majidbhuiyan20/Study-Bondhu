import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../models/flashcard.dart';

class FlashcardsState {
  final bool isLoading;
  final List<FlashcardDeck> decks;
  const FlashcardsState({this.isLoading = false, this.decks = const []});
  FlashcardsState copyWith({bool? isLoading, List<FlashcardDeck>? decks}) =>
      FlashcardsState(
        isLoading: isLoading ?? this.isLoading,
        decks: decks ?? this.decks,
      );
}

class FlashcardsViewModel extends StateNotifier<FlashcardsState> {
  FlashcardsViewModel(this._ref) : super(const FlashcardsState());
  final Ref _ref;

  void bootstrap() {
    Future.microtask(load);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final list =
        await _ref.read(flashcardsRepositoryProvider).getDecks();
    state = FlashcardsState(isLoading: false, decks: list);
  }

  Future<int> addDeck(FlashcardDeck d) async {
    final id =
        await _ref.read(flashcardsRepositoryProvider).addDeck(d);
    await load();
    return id;
  }

  Future<void> deleteDeck(int id) async {
    await _ref.read(flashcardsRepositoryProvider).deleteDeck(id);
    await load();
  }

  Future<List<Flashcard>> getCards(int deckId) =>
      _ref.read(flashcardsRepositoryProvider).getCards(deckId);

  Future<int> addCard(Flashcard c) async {
    final id =
        await _ref.read(flashcardsRepositoryProvider).addCard(c);
    return id;
  }

  Future<void> deleteCard(int id) async {
    await _ref.read(flashcardsRepositoryProvider).deleteCard(id);
  }

  Future<void> recordReview(int cardId, int quality) async {
    await _ref
        .read(flashcardsRepositoryProvider)
        .recordReview(cardId, quality);
  }
}

final flashcardsViewModelProvider =
    StateNotifierProvider<FlashcardsViewModel, FlashcardsState>(
  (ref) => FlashcardsViewModel(ref),
);