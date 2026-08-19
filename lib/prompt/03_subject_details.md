# 03 — Subject Details

The hub page for a single subject. When the student taps a subject card on
the Subjects screen, they land here.

## Goals

- Provide a single screen that summarizes everything about one subject.
- Allow drilling into each sub-feature (syllabus, topics, assignments, …).
- Be the "home" for a subject — a place the student returns to repeatedly.

## Visual layout

```
┌──────────────────────────────────────────┐
│ ← Operating System                  ⋮     │
├──────────────────────────────────────────┤
│  ┌────────────────────────────────────┐  │
│  │  📘 Operating System               │  │
│  │  CSE-321 • 3 Credits • Mr. Karim   │  │
│  │  ████████░░ 72% syllabus complete  │  │
│  └────────────────────────────────────┘  │
│                                          │
│  [ Syllabus ][ Topics ][ Assignments ]   │
│  [ Exams ][ Attendance ][ Study ][ Notes]│
│                                          │
│  ┌─ Tab content ─────────────────────┐  │
│  │                                    │  │
│  │  (active tab)                      │  │
│  │                                    │  │
│  └────────────────────────────────────┘  │
└──────────────────────────────────────────┘
```

## Header

```
┌──────────────────────────────────────────┐
│  [icon]  Operating System                │
│          CSE-321 • 3 Credits • Mr. Karim │
│                                          │
│  ████████░░ 72% syllabus complete        │
└──────────────────────────────────────────┘
```

- Color swatch icon (subject's color).
- Title: `Subject.name` (titleLarge).
- Subtitle: `code • credit • teacher` (bodySmall, optional fields hidden).
- Progress bar: syllabus completion %
  (`syllabus_done / syllabus_total`).
- Streak chip / weak-topic chip (V2).

The header is a single `AppCard` with a colored leading icon.

## Tabs

`DefaultTabController(length: 7)`. Order matters — most-used first.

| # | Tab name    | English        | Bangla         | Widget                                 |
| - | ----------- | -------------- | -------------- | -------------------------------------- |
| 1 | Syllabus    | Syllabus       | সিলেবাস          | `SubjectSyllabusView`                  |
| 2 | Topics      | Topics         | বিষয়সমূহ         | `SubjectTopicsView`                    |
| 3 | Assignments | Assignments    | অ্যাসাইনমেন্ট     | `SubjectAssignmentsView`               |
| 4 | Exams       | Exams          | পরীক্ষা          | `SubjectExamsView`                     |
| 5 | Attendance  | Attendance     | উপস্থিতি         | `SubjectAttendanceView`                |
| 6 | Study Time  | Study Time     | পড়ার সময়       | `SubjectStudyTimeView`                 |
| 7 | Notes       | Notes          | নোট             | `SubjectNotesView`                     |

The tab bar is scrollable (use `TabBar(isScrollable: true)`) so it fits on
narrow screens.

Each tab content is a `FutureBuilder` or `Consumer` that reads from the
appropriate FutureProvider / repository, filtered by `subjectId`.

## Tab content contracts

### 1. Syllabus tab

See `04_syllabus_tracker.md` for the full spec.

- Reorderable list of `SyllabusItem`.
- Tap checkbox to toggle done.
- FAB → "Add syllabus item".
- Empty state: "Add your syllabus to track progress".

### 2. Topics tab

See `05_topic_status.md` for the full spec.

- Hierarchical list of topics + sub-topics.
- Each topic has a status chip (⚪ not started / 🟡 learning / 🔴 weak / 🟢
  mastered).
- FAB → "Add topic".
- Tap topic → edit sheet (rename, change status, delete).

### 3. Assignments tab

- Filtered by `subjectId`.
- Same card UI as the main Assignments screen.
- Empty state: "No assignments for this subject".

### 4. Exams tab

- Filtered by `subjectId`.
- Card shows exam date + days left.
- Tap → exam preparation screen (see `09_exam_preparation.md`).

### 5. Attendance tab

- Compact view: stats card + quick-mark buttons (Present / Late / Absent).
- Tapping "View scenarios" opens the what-if sheet (see `17_attendance.md`).

### 6. Study Time tab

- Aggregated stats for this subject:
  - Total hours (all-time)
  - Last 7 days bar chart
  - Average session length
  - Most-studied topic
- "Start Study" CTA → opens Focus Mode with subject pre-selected.

### 7. Notes tab

- Filtered by `subjectId`.
- Same as the main Notes screen.
- FAB → "New note" (auto-tags the subject).

## Files

```
lib/features/subjects/
├── views/
│   ├── subject_detail_view.dart       # top-level screen
│   └── tabs/
│       ├── subject_syllabus_view.dart
│       ├── subject_topics_view.dart
│       ├── subject_assignments_view.dart
│       ├── subject_exams_view.dart
│       ├── subject_attendance_view.dart
│       ├── subject_study_time_view.dart
│       └── subject_notes_view.dart
└── widgets/
    ├── subject_detail_header.dart    # icon + title + progress bar
    └── subject_tab_bar.dart          # the scrollable TabBar
```

## Routing

- Path: `/subjects/:id`
- `id` is `Subject.id` (integer).
- The detail view reads `subjectId` from `GoRouterState.of(context).pathParameters`.
- If the subject doesn't exist (deleted from another screen), show a 404
  snackbar and pop.

Add to `lib/core/app_router.dart`:

```dart
GoRoute(
  path: AppRoutes.subjectDetail,
  builder: (context, state) {
    final id = int.parse(state.pathParameters['id']!);
    return SubjectDetailView(subjectId: id);
  },
),
```

## ViewModel

This screen **does not own a ViewModel**. It reads from other providers
that already exist:

- `subjectsRepositoryProvider.getSubject(id)` → header data
- `syllabusForSubjectProvider(id)` (FutureProvider.family.autoDispose)
- `topicsForSubjectProvider(id)` (FutureProvider.family.autoDispose)
- `assignmentsRepositoryProvider.getAssignments(subjectId: id)`
- `examsRepositoryProvider.getExams(subjectId: id)`
- `attendanceRepositoryProvider.getStats(subjectId: id)`
- `studyRepositoryProvider.getSessionsBySubject(id)` (V2)
- `notesRepositoryProvider.getNotes(subjectId: id)`

Each is wrapped in a `FutureProvider.family.autoDispose` so the subject
data is loaded on demand and disposed when the user leaves the screen.

## Edit subject (from app bar `⋮` menu)

```
Edit subject
Delete subject
Share (V2)
```

### Edit subject

Bottom sheet with fields:

- Name
- Code
- Teacher
- Credit
- Color (palette)
- Target attendance (slider 50–100, default 75)

### Delete subject

Confirmation dialog:

```
Delete "Operating System"?

This will permanently remove:
• 24 syllabus items
• 12 topics
• 5 assignments
• 2 exams
• 32 attendance records
• 18 study sessions ("12h 30m")
• 7 notes
• 3 flashcards

This action cannot be undone.

[ Cancel ]   [ Delete ]
```

Show the count of each related item so the user knows what they're losing.

## App bar actions

- `←` back
- `⋮` menu: Edit, Delete

## Progress bar calculation

```dart
final pct = syllabus.isEmpty
    ? 0.0
    : syllabus.where((s) => s.isDone).length / syllabus.length;
```

Shown at 1 decimal place rounded to integer.

## Performance

- Tabs are lazy — only the active tab's content is built.
- `TabBarView` with `physics: BouncingScrollPhysics()` for smooth
  switching.
- `AutomaticKeepAliveClientMixin` is **not** needed — each tab re-fetches
  on activation (data is small).

## Edge cases

- **Subject not found** — show snackbar + pop.
- **Subject with no related data** — each tab shows its own empty state.
- **Tab swap while loading** — each tab has its own loader.
- **Edit subject via sheet** — applies immediately on save; optimistic
  update.
- **Delete subject** — cascade via FK ON DELETE CASCADE; subjects list
  re-loads via `SubjectsViewModel.load()`.

## Bangla strings

| English         | Bangla        |
| --------------- | ------------- |
| Subjects        | বিষয়সমূহ       |
| Syllabus        | সিলেবাস         |
| Topics          | বিষয়সমূহ       |
| Assignments     | অ্যাসাইনমেন্ট     |
| Exams           | পরীক্ষা          |
| Attendance      | উপস্থিতি        |
| Study Time      | পড়ার সময়       |
| Notes           | নোট            |
| 72% syllabus complete | সিলেবাস ৭২% সম্পন্ন |
| Edit subject    | বিষয় সম্পাদনা   |
| Delete subject  | বিষয় মুছুন       |
| CSE-321 • 3 Credits | CSE-321 • ৩ ক্রেডিট |

## Dark mode

- Header card uses `ThemeColors.surface`.
- Tab indicator uses `AppColors.primary` (works in both modes).
- Tabs use `ThemeColors.textPrimary` for active, `textSecondary` for
  inactive.
- Each tab's content is theme-aware (covered by its own spec).

## Riverpod rules

- `SubjectDetailView` is `ConsumerStatefulWidget`.
- The future providers are auto-disposed; loaded on first watch.
- `initState` triggers `ref.invalidate(...)` on the relevant providers if
  the screen is re-entered (e.g. after editing).

## Linked features

- **02 — Subjects**: parent list.
- **04 — Syllabus Tracker** (this tab).
- **05 — Topic Status** (this tab).
- **06 — Assignment Manager** (this tab).
- **08 — Exam Manager** (this tab).
- **17 — Attendance** (this tab).
- **18 — Notes** (this tab).
- **12 — Focus Mode**: "Start Study" CTA opens with subject pre-selected.

## Done criteria

- [ ] All 7 tabs render with subject-specific data.
- [ ] Tab data is filtered by `subjectId`.
- [ ] Header shows correct progress %.
- [ ] Edit subject saves and updates the header.
- [ ] Delete subject cascades correctly.
- [ ] Tapping "Start Study" navigates to `/study` with subject set.
- [ ] No assertion errors on launch.
- [ ] Dark mode: all tabs legible.
- [ ] Bangla tab labels render correctly.
- [ ] Tests pass; `flutter analyze` clean.