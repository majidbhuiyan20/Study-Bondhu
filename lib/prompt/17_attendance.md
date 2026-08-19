# 17 — Attendance

Per-subject attendance tracking with a target percentage.

## Model

```dart
enum AttendanceStatus { present, late, absent }

class AttendanceRecord {
  final int? id;
  final int subjectId;
  final DateTime date;
  final AttendanceStatus status;
  final DateTime createdAt;
}
```

`Subject.targetAttendance` (default 75) is the goal.

## UI

For each subject:

```
Operating System

Present: 28
Absent:  4
Total:   32

87.5%

Target: 75%
```

Three quick-mark buttons per row: Present / Late / Absent.

## What-if scenarios

Tapping "View scenarios" → bottom sheet:

```
You can miss 2 more classes
and stay above 75%.
```

Math:

```
maxAbsents = floor((totalClasses × target) / 100) - presentClasses
```

Clamp to ≥ 0.

## Files

```
lib/features/attendance/
├── models/attendance_record.dart
├── repositories/attendance_repository.dart
├── view_models/attendance_view_model.dart
├── views/attendance_view.dart
└── widgets/attendance_row.dart
```

`attendanceStatsProvider` is a `FutureProvider.autoDispose` returning a
`Map<subjectId, AttendanceStats>`.