# 16 — Weakness Radar

Visualizes the student's weak areas across subjects, derived from their own
data (not AI diagnosis).

## Data sources

- `Topic.status == weak` (primary)
- `StudySession.focusRating <= 2` (low ratings)
- Revision completion rate (less reliable)
- Assignment progress (stalled assignments)

## UI

Two views:

1. **Per-subject weak topics** (lives on Subject Details)
   ```
   Operating System
     🔴 Round Robin
     🔴 Deadlock
   ```
2. **Cross-subject radar** (lives on Analytics screen)
   - A radar chart with one axis per subject.
   - Each axis extends to the proportion of weak topics for that subject.
   - Requires ≥ 3 subjects; otherwise show a friendly message:
     "Add at least 3 subjects to see the weakness radar."

## Files

```
lib/features/analytics/widgets/weakness_radar_card.dart
lib/features/subjects/widgets/subject_weak_topics.dart
```

## Why this is not "AI"

The radar is purely a deterministic aggregation. No model, no prediction.
It is honest about what the student has marked weak. Future versions may
add heuristic boosts (e.g. recent low ratings), but for V1 it's transparent.