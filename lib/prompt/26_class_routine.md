# 26 — Class Routine

Weekly class timetable. Useful for university students.

## Model

```dart
class ClassSlot {
  final int? id;
  final int subjectId;
  final int dayOfWeek;     // 1=Mon..7=Sun
  final String startTime;  // "09:00"
  final String endTime;    // "10:00"
  final String? location;
  final DateTime createdAt;
}
```

## UI

- Week view (Mon–Sun columns) or list view (toggle in header).
- Color-coded by subject.
- Tap slot → edit / delete.

## Home integration

When the user opens Home, show:

```
Next class: Operating System — 45 min
            Today 11:00 AM
            Room 301
```

## Files

```
lib/features/routine/
├── models/class_slot.dart
├── repositories/class_routine_repository.dart
├── view_models/class_routine_view_model.dart
└── views/class_routine_view.dart
```

Note: distinct from the **Daily/weekly habits** Routines feature (see
existing `lib/features/routines/`). Naming may collide; consider renaming
either the habits one to `habits/` or the timetable one to `timetable/`
in V2 to avoid confusion.