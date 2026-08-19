# Database — SQLite Schema

StudyBondhu is offline-first. Everything lives in a single SQLite database
opened through `sqflite` and exposed via `AppDatabase`.

```
lib/database/
├── app_database.dart          # opens DB, runs migrations
├── database_tables.dart       # table names + column constants
└── (one *_dao.dart per feature)
```

## Schema (v2)

| Table               | Purpose                                                     |
| ------------------- | ----------------------------------------------------------- |
| `profiles`          | Student profile (school/college/university/madrasa/coaching). One row per profile. |
| `semesters`         | Semester per profile. `profile_id` (nullable for legacy).   |
| `subjects`          | Subject per semester. `color`, `credit`, `target_attendance`. |
| `topics`            | Topic per subject. `status` (not_started/learning/weak/mastered). |
| `syllabus_items`    | Syllabus entry per subject. Ordered, with `is_done`.       |
| `assignments`       | Tasks, deadlines, subtasks.                                 |
| `assignment_subtasks` | Subtasks with checkbox + ordering.                        |
| `exams`             | Exam date, time, location, syllabus % ready.                 |
| `study_sessions`    | Logged timer sessions. `duration_seconds`, `focus_rating`.  |
| `revisions`         | Scheduled revision events.                                 |
| `notes`             | Free-form notes.                                            |
| `note_topics`       | Topic a note belongs to (nullable).                        |
| `flashcard_decks`   | Deck of flashcards.                                          |
| `flashcards`        | Front / back of a card.                                      |
| `flashcard_reviews` | Spaced-repetition review history.                          |
| `attendance_records`| Per-day attendance status per subject.                      |
| `expenses`          | Expense with category and amount.                           |
| `routines`          | Daily/weekly recurring routines.                            |
| `goals`             | User-defined goals (daily/weekly/total minutes).            |

## Versioning

- Bump `AppConstants.dbVersion` in `core/constants/app_constants.dart`
  whenever a column or table is added.
- Add a new branch in `AppDatabase.onUpgrade`:
  ```dart
  if (oldVersion < 3) {
    await db.execute("ALTER TABLE subjects ADD COLUMN ...");
  }
  ```
- Always preserve existing data. Never drop a table that has user data.

## Conventions

- IDs are `INTEGER PRIMARY KEY AUTOINCREMENT`.
- Timestamps are stored as ISO-8601 strings (`TEXT`).
- Booleans are `INTEGER` (0/1).
- Foreign keys are declared with `REFERENCES table(id) ON DELETE CASCADE`.
- Use the `*Tables` constants in `database_tables.dart` instead of string
  literals — this catches typos at compile time.

## Repositories

One repository per table. Each repository:

- Takes an `AppDatabase` in its constructor.
- Exposes `getAll()`, `getById(int)`, `insert(T)`, `update(T)`, `delete(int)`.
- Returns model objects (not `Map<String, dynamic>`).
- Never holds Riverpod state.

Repositories are constructed once in `core/providers.dart` and exposed as
Providers. ViewModels depend on repositories, not on `AppDatabase`
directly.