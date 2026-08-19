# 22 — Goals

User-defined goals for the semester.

## Model

```dart
enum GoalType { daily, weekly, total }

class Goal {
  final int? id;
  final String title;
  final GoalType type;
  final int target;            // minutes
  final double progress;       // 0..1
  final DateTime createdAt;
}
```

## UI

- List of goals with progress bars.
- Segmented buttons: Daily / Weekly / Total.
- Slider sets target.
- Add / delete via bottom sheet.

## Files

```
lib/features/home/models/goal.dart
lib/features/analytics/view_models/analytics_view_model.dart
lib/features/analytics/widgets/goal_tile.dart
```

`AnalyticsViewModel.addGoal / deleteGoal / getGoals`.

## Derived

- Daily goal progress feeds Home Dashboard ("Today's progress").
- Weekly / total goals feed Analytics screen.