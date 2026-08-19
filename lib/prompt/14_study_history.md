# 14 — Study History

Every completed session is logged and viewable.

## Grouping

The history view groups by day by default. Tabs at the top:

- Day
- Week
- Month
- Subject
- Topic

## Day view

```
17 August

OS         45 min  CPU Scheduling
DBMS       30 min  Normalization
Math       25 min  Integration

Total                1h 40m
```

Tap a session to edit notes / delete.

## Files

```
lib/features/study/views/study_log_view.dart
lib/features/study/widgets/session_tile.dart
```

`studyViewModelProvider.sessions` is the data source; sessions are
sorted desc by `startTime`.

## Edge cases

- No sessions → "Use the timer to log study sessions".
- Deleting a session → confirmation dialog.