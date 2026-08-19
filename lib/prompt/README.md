# StudyBondhu — Product & Engineering Prompt Library

This folder is the **single source of truth** for the StudyBondhu product. Every
feature, design decision, screen, data model, and engineering rule lives here so
that AI agents (and human contributors) can build, review, and refactor the
codebase without rediscovering context every time.

> Use this README as the **table of contents**. Each numbered topic in the
> master spec has its own file in this folder.

---

## How to use this folder

When you ask the assistant to work on a feature, **reference the matching file
by name**, e.g.:

> "Implement feature 14 — Study History. See `lib/prompt/14_study_history.md`."

The assistant will read the spec, audit the existing code, and produce the
implementation. Likewise, for review work, point at the relevant file.

---

## Index of features

| #   | Title                              | File                                              | Status |
| --- | ---------------------------------- | ------------------------------------------------- | ------ |
| 01  | Home Dashboard                     | `01_home_dashboard.md`                            |        |
| 02  | Subjects                           | `02_subjects.md`                                  |        |
| 03  | Subject Details                    | `03_subject_details.md`                           |        |
| 04  | Syllabus Tracker                   | `04_syllabus_tracker.md`                          |        |
| 05  | Topic Status                       | `05_topic_status.md`                              |        |
| 06  | Assignment Manager                 | `06_assignment_manager.md`                        |        |
| 07  | Deadline Management                | `07_deadline_management.md`                       |        |
| 08  | Exam Manager                       | `08_exam_manager.md`                              |        |
| 09  | Exam Preparation Mode              | `09_exam_preparation.md`                          |        |
| 10  | Smart Revision System              | `10_smart_revision.md`                            |        |
| 11  | "What Should I Study Now?"         | `11_what_to_study_now.md`                         |        |
| 12  | Focus Mode (Study Timer)           | `12_focus_mode.md`                                |        |
| 13  | Study Session Completion           | `13_session_completion.md`                        |        |
| 14  | Study History                      | `14_study_history.md`                             |        |
| 15  | Study Analytics                    | `15_study_analytics.md`                           |        |
| 16  | Weakness Radar                     | `16_weakness_radar.md`                            |        |
| 17  | Attendance                         | `17_attendance.md`                                |        |
| 18  | Notes                              | `18_notes.md`                                     |        |
| 19  | Flashcards                         | `19_flashcards.md`                                |        |
| 20  | Student Expenses                   | `20_expenses.md`                                  |        |
| 21  | Semester Timeline                  | `21_semester_timeline.md`                         |        |
| 22  | Goals                              | `22_goals.md`                                     |        |
| 23  | Study Streak                       | `23_study_streak.md`                              |        |
| 24  | Notifications                      | `24_notifications.md`                             |        |
| 25  | Global Search                      | `25_global_search.md`                             |        |
| 26  | Class Routine                      | `26_class_routine.md`                             |        |
| 27  | Local Files / Resources            | `27_local_files.md`                               |        |
| 28  | Bangla + English                   | `28_localization.md`                              |        |
| 29  | Dark Mode                          | `29_dark_mode.md`                                 |        |
| 30  | Offline-First                      | `30_offline_first.md`                             |        |
| 31  | Backup (Later)                     | `31_backup.md`                                    |        |
| 32  | AI (Future)                        | `32_ai_future.md`                                 |        |
| 33  | Bangladesh-Focused Onboarding      | `33_bd_onboarding.md`                             |        |
| 34  | Student Profile                    | `34_student_profile.md`                           |        |
| 35  | Quick Add                          | `35_quick_add.md`                                 |        |
| 36  | Privacy                            | `36_privacy.md`                                   |        |

Status legend: ✅ done · 🟡 partial · ⬜ not started

---

## Engineering conventions

These are the *non-negotiable* rules every contributor must follow. They are
described in detail in the files listed below.

| Topic                       | File                                          |
| --------------------------- | --------------------------------------------- |
| MVVM architecture           | `architecture_mvvm.md`                        |
| Riverpod rules              | `architecture_riverpod.md`                    |
| Theming & dark mode         | `theming_and_dark_mode.md`                    |
| Database / SQLite schema    | `database_schema.md`                          |
| Localization patterns       | `localization_patterns.md`                    |
| Testing expectations        | `testing.md`                                  |

---

## Master flow (the heart of the app)

```
Student
   ↓
Subjects
   ↓
Topics
   ↓
Study + Revision + Notes
   ↓
Confidence + Revision Data
   ↓
Weakness Analysis
   ↓
Exam Preparation
   ↓
"What should I study?"
   ↓
Study Plan
   ↓
Progress
```

Every feature should ladder up to this flow. If a new feature does not feed
into "What should I study?", question whether it belongs.

---

## MVP scope (V1)

For V1 we ship: Home, Subjects, Syllabus, Topics, Assignments, Exams,
Attendance, Study Timer, Revision, What-to-study, Basic Progress,
Notifications, Dark Mode, Bangla/English, Offline SQLite.

V2 adds: Notes, Flashcards, Advanced Analytics, Goals, Study Streak,
Class Routine, Local Files, Expenses.