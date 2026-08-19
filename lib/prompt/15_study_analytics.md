# 15 — Study Analytics

Aggregated stats for the student.

## Stat cards (top of analytics screen)

- Total study time
- Number of sessions
- Streak days
- Average focus rating

## Weekly chart

Bar chart of study time per day for the last 7 days:

```
Mon ████░░░░ 1h 30m
Tue ██████░░ 2h 10m
Wed ██░░░░░░ 45m
...
```

## Derived insights

- Most studied subject (last 7 days)
- Least studied subject
- Most productive day of the week
- Total completed topics
- Revision count

## Files

```
lib/features/analytics/
├── view_models/analytics_view_model.dart
├── views/analytics_view.dart
└── widgets/
    ├── stat_card.dart
    ├── weekly_chart.dart   # bar chart
    └── goals_section.dart
```

## Charts

Use `fl_chart`. BarChart for weekly, RadarChart for weakness (see
`16_weakness_radar.md`).

**Important:** `RadarChart` requires **at least 3 entries**. Guard with a
check; show an empty-state card otherwise.