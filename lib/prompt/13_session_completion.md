# 13 — Study Session Completion

When the user stops the timer, we show a session-complete sheet that:

1. Confirms the session.
2. Asks for confidence rating.
3. Lets them add notes.

## Sheet layout

```
🎉 Session Complete

45 minutes

Operating System
Round Robin

Today's Study
2h 35m

How confident are you?

😕 Weak    🙂 Okay    😎 Strong

[ Notes (optional) ]

[ Skip ]   [ Save ]
```

## Effect on data

- Save → updates `StudySession.focusRating` (1, 3, 5) and `notes`.
- If a `topicId` was set:
  - rating 1 → `Topic.status = weak`
  - rating 5 → `Topic.status = mastered`
  - rating 3 → unchanged
- Schedules next revision (see `10_smart_revision.md`).
- Updates Home Dashboard's todaySeconds immediately.

## Files

```
lib/features/study/widgets/session_complete_sheet.dart
lib/features/study/view_models/study_view_model.dart  # updateSession()
```

## Why a sheet (not a dialog)

Modal bottom sheet is less interruptive than a full-screen dialog, plays
well with `MediaQuery.viewInsets.bottom` for keyboard, and is themable.