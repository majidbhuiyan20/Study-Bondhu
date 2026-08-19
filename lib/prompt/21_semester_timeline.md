# 21 — Semester Timeline

A high-level view of the semester's events on a vertical timeline.

```
August
 │
 ├── Classes
 │
 ├── Assignment
 │     • DBMS Homework   17 Aug
 │     • OS Lab Report   20 Aug
 │
 ├── Midterm             22 Aug
 │
 ├── Presentation        28 Aug
 │
 ├── Lab Exam            5 Sep
 │
 └── Final Exam          15 Sep
```

## Data sources

- Assignments with `dueDate` in semester range.
- Exams with `examDate` in semester range.
- Routines that fall in the semester (collapsed into "Classes").

## Files

```
lib/features/subjects/
├── views/semester_timeline_view.dart
└── widgets/timeline_event.dart
```

## Implementation

- Single screen, `ListView` grouped by month.
- Each event is a chip with category color.
- Tapping an event deep-links to its detail (assignment, exam, etc.).

This is mostly a **read-only** view; all mutations happen on the source
screens.