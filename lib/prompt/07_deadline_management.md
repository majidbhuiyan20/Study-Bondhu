# 07 — Deadline Management

Tracks upcoming deadlines across assignments and exams. Feeds Home
Dashboard and notifications.

## Sources

- Assignments with `dueDate` in the future
- Exams with `examDate` in the future

## Buckets

| Bucket    | Range                          | Color |
| --------- | ------------------------------ | ----- |
| Today     | due == today                   | 🔴    |
| Tomorrow  | due == today + 1               | 🔴    |
| 3 Days    | within 3 days                  | 🟡    |
| 7 Days    | within 7 days                  | 🟢    |
| Later     | > 7 days                       | —     |

## Surfaces

- **Home Dashboard** → "Today's Tasks" and "Upcoming Exams" sections.
- **Notifications** → morning reminder for items due in 1–2 days.
- **Bottom nav** → dedicated Tasks/More screen.

## Files

```
lib/features/assignments/views/assignments_view.dart
lib/features/exams/views/exams_view.dart
lib/features/home/widgets/today_tasks_section.dart
lib/features/home/widgets/upcoming_exam_card.dart
lib/core/services/notification_service.dart   # schedules reminders
```

## Reminder policy

- Assignment due in 1 day → notify at 8 PM the day before.
- Exam in 3 days → notify each morning.
- User can disable per category in Settings.