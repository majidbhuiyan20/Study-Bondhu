# 04 — Syllabus Tracker

Students enter the syllabus for each subject manually. Each entry has a
status: ⬜ not started, 🟡 in progress, ✅ done.

## Model

```dart
class SyllabusItem {
  final int? id;
  final int subjectId;
  final String title;
  final int orderIndex;
  final bool isDone;
  final DateTime createdAt;
}
```

## UI

- Reorderable list (drag handle on the right).
- Tap checkbox to toggle done.
- Tap title to rename inline.
- "+ Add item" button at the bottom.
- Progress bar at the top: `done / total`.

## Files

```
lib/features/subjects/
├── models/syllabus_item.dart
├── widgets/syllabus_tile.dart
└── (uses subjectsViewModelProvider — no separate VM)
```

`SubjectsViewModel` exposes `addSyllabus`, `toggleSyllabus`, `deleteSyllabus`.

## Used by

- Subject Details (tab)
- Exam Preparation Mode (calculates syllabus % per subject)
- What Should I Study Now (incomplete syllabus items are recommended)
- Subject Details header progress bar

## Edge cases

- Deleting a subject cascades — its syllabus items are removed too.
- Empty syllabus → progress shows 0%, no crash.