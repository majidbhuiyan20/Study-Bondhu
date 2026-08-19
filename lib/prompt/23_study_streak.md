# 23 — Study Streak

Counts consecutive days where the student met the daily goal.

## Calculation

```
For each day d (desc):
  if studyTime(d) >= dailyGoal: streak++
  elif d == today:               continue (today not yet over)
  else:                          break
```

## UI

- **Home Dashboard** → small 🔥 chip with day count.
- **Settings → More** → large streak card with monthly calendar heatmap.

## Calendar heatmap

```
August 2025

Mo Tu We Th Fr Sa Su
            1  2  3
 � 🟢 🟢 🟢 🟢 🟢
 🟢 � 🔴 🟢 🟢 🟢
 🟢 🟢 � 🟢 🟢 🟢
```

- 🟢 met goal
- � partial (≥ 50% of goal)
- 🔴 below
- ⬜ no study

## Files

```
lib/features/home/widgets/today_progress_card.dart   # streak chip
lib/features/profile/views/streak_view.dart           # full screen
```

## Tone

Keep it **motivational, not punishing**. If the streak breaks, show "Start
a new streak today" instead of "You lost your streak".