# 25 — Global Search

One search box that searches across multiple repositories.

## Indexed

- Subjects
- Topics
- Assignments
- Exams
- Notes
- Flashcards

## UI

```
🔍 Search…

Round Robin

� OS Topic
🧠 Revision
🗒 Note
🃏 Flashcard
```

## Implementation

- Top-level screen with a `TextField` and a `ListView` of grouped results.
- Uses a `searchProvider` that calls a service-layer search across all
  repositories in parallel.
- Case-insensitive substring match (V1). Fuzzy match is V2.

## Files

```
lib/features/search/
├── views/search_view.dart
└── view_models/search_view_model.dart
```

Reachable from the More tab and as a `cmd+k` style shortcut (mobile: tap
search icon in app bar).