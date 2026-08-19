# 19 — Flashcards

Simple front/back cards with spaced repetition.

## Model

```dart
class FlashcardDeck {
  final int? id;
  final String name;
  final DateTime createdAt;
}

class Flashcard {
  final int? id;
  final int deckId;
  final String front;
  final String back;
  final DateTime createdAt;
}

class FlashcardReview {
  final int? id;
  final int cardId;
  final int quality;       // 1, 3, 5 (again / good / easy)
  final DateTime reviewedAt;
}
```

## Review session

```
Front: What is FCFS?

[ Show answer ]

😕 Again    🙂 Good    😎 Easy
```

Updates the next due date (simple SM-2-ish).

## Files

```
lib/features/flashcards/
├── models/flashcard.dart
├── repositories/flashcards_repository.dart
├── view_models/flashcards_view_model.dart
├── views/flashcards_view.dart
├── views/flashcard_deck_view.dart
└── views/flashcard_study_view.dart
```

## Linked to

- Subject Details (optional tab in V2).
- Global Search (25).