# 08 — Exam Manager

Students create exams with date, time, subject, location, syllabus
progress, notes.

## Model

```dart
class Exam {
  final int? id;
  final String title;
  final int subjectId;
  final DateTime examDate;
  final String? time;          // "09:00 – 11:00"
  final String? location;
  final String? notes;
  final DateTime createdAt;
}
```

## UI

- **List view** sorted by exam date (asc).
- Each card shows:
  - Subject color band + name
  - Title
  - Days left (e.g. "5 days left", "Tomorrow")
  - Location chip if set
- Tap → exam detail screen.

## Add form (`/exams/add`)

- Title
- Subject (required)
- Exam date
- Time (optional, text)
- Location (optional)
- Notes (optional)

## Files

```
lib/features/exams/
├── models/exam.dart
├── repositories/exams_repository.dart
├── view_models/exams_view_model.dart
├── views/exams_view.dart
├── views/exam_add_view.dart
└── widgets/exam_card.dart
```

## Preparation % (linked to feature 09)

Computed by:

```
0.4 × syllabus_done_pct
+ 0.3 × revision_done_pct
+ 0.2 × study_hours / estimated_hours
+ 0.1 × topic_mastered_pct
```