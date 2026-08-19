# 36 — Privacy

Personal offline app. Privacy is a feature, not a footnote.

## V1 commitments

- ✅ No account required.
- ✅ No data leaves the device unless explicitly backed up by the user.
- ✅ No third-party analytics, no ad SDKs, no tracking.
- ✅ No permissions requested at install; only when needed (notifications
  opt-in, file picker opt-in).

## Permissions

| Permission                  | When requested                |
| --------------------------- | ----------------------------- |
| Notifications               | First toggle ON in Settings.  |
| Storage / file picker       | Tap "Attach resource".        |
| Exact alarm (Android 12+)   | Schedule a notification.      |

Each request comes with a one-sentence explanation.

## V2 commitments (when cloud backup ships)

- Cloud backup is **opt-in** and **explicit**.
- The user picks the destination (Google Drive / iCloud) and confirms.
- No silent background uploads.
- The user can delete all cloud data with one tap in Settings.

## Future-proofing

- All repositories write only to the local SQLite database.
- All settings live in `shared_preferences`.
- No `HttpClient` calls in the codebase; CI fails if any are added
  without an explicit comment.

## Files

```
lib/core/services/local_storage_service.dart
lib/core/services/notification_service.dart
lib/database/app_database.dart
```