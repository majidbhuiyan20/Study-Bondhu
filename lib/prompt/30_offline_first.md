# 30 — Offline-First

StudyBondhu is **offline-first**. Every feature works without internet.

## What works offline

| Feature          | Offline |
| ---------------- | :-----: |
| Subjects         |   ✅    |
| Syllabus         |   ✅    |
| Assignments      |   ✅    |
| Exams            |   ✅    |
| Attendance       |   ✅    |
| Study Timer      |   ✅    |
| Revision         |   ✅    |
| Notes            |   ✅    |
| Flashcards       |   ✅    |
| Analytics        |   ✅    |
| Expenses         |   ✅    |
| Notifications    |   ✅ (local) |
| Bangla/English   |   ✅    |
| Dark Mode        |   ✅    |

## Storage

- SQLite via `sqflite` for structured data.
- `shared_preferences` for settings (locale, theme, daily goal, …).
- Local file paths for resources (see `27_local_files.md`).

## Network code

There is **no network code in V1**. If a feature seems to require it
(sync, AI, cloud backup), it belongs to V2 or later.

## Testing offline behavior

When developing a new feature, verify:

1. With airplane mode on, the feature still loads.
2. After a fresh install (no data), the app shows a graceful empty state.
3. With large data (1000+ sessions), the app still feels responsive.

See `31_backup.md` for the cloud story in V2+.