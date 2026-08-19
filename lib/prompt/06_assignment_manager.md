# 06 — Assignment Manager

Tasks, homework, projects, presentations, lab reports, etc.

## Types

```dart
enum AssignmentType {
  assignment,
  homework,
  project,
  presentation,
  labWork,
  report,
}
```

## Model

```dart
class Assignment {
  final int? id;
  final String title;
  final AssignmentType type;
  final int? subjectId;
  final int? topicId;
  final DateTime? dueDate;
  final AssignmentPriority priority; // low, medium, high
  final int estimatedMinutes;
  final double progress;             // 0..1
  final AssignmentStatus status;     // pending, completed
  final String? notes;
  final DateTime createdAt;
}
```

## Subtasks

Large assignments can be broken down:

```dart
class AssignmentSubtask {
  final int? id;
  final int assignmentId;
  final String title;
  final bool isDone;
  final int orderIndex;
}
```

## UI

- **List view** with two sections: Pending (sorted by due date) and
  Completed.
- Tap the row to toggle complete.
- Tap-and-hold (or icon) for edit / delete / add subtask.
- Subtask progress shows as a thin bar above the title.

## Add form (`/assignments/add`)

- Title (required)
- Type (segmented buttons)
- Subject (optional dropdown)
- Topic (optional, depends on subject)
- Due date (date picker)
- Priority (chips)
- Estimated minutes
- Notes

## Files

```
lib/features/assignments/
├── models/assignment.dart
├── models/assignment_subtask.dart
├── repositories/assignments_repository.dart
├── view_models/assignments_view_model.dart
├── views/assignments_view.dart
├── views/assignment_add_view.dart
└── widgets/assignment_card.dart
```

## Deadlines (linked to feature 07)

See `07_deadline_management.md` for how deadlines are surfaced across the
app.