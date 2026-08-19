# 24 — Notifications

Local notifications via `flutter_local_notifications`.

## Categories

| Category      | Trigger                                |
| ------------- | -------------------------------------- |
| Assignment    | Due in 1 day (8 PM the day before).    |
| Revision      | Topic due today (morning).             |
| Exam          | Exam in 1, 3, 7 days (morning).        |
| Study goal    | Daily goal not yet met (8 PM).         |
| Attendance    | Subject drops below target.            |

## User controls

Settings → Notifications. Each category has its own toggle:

```
☑ Assignment reminders
☑ Revision reminders
☑ Exam reminders
☑ Daily goal reminder
☐ Attendance alerts
```

## Implementation

```
lib/core/services/notification_service.dart
```

- Single `NotificationService` singleton.
- `init()` called from `StudyBondhuApp.initState`.
- `requestPermissions()` called when toggling on.
- `scheduleAll()` called on app start to re-schedule pending items.
- Reads from `assignmentsRepository`, `revisionsRepository`,
  `examsRepository` etc. directly (no Riverpod in service layer — pass
  repos via constructor).

## Timezone

Use `timezone` package; default to `Asia/Dhaka`.