# 02 — Subjects

The student creates their academic structure here. A subject belongs to a
semester, which belongs to a profile.

## Hierarchy

```
Profile (school / college / university / madrasa / coaching)
 └── Semester (Fall 2025, 7th Semester, etc.)
      └── Subject
           ├── Topics              (see 05_topic_status.md)
           ├── Syllabus            (see 04_syllabus_tracker.md)
           ├── Assignments         (see 06_assignment_manager.md)
           ├── Exams               (see 08_exam_manager.md)
           ├── Notes               (see 18_notes.md)
           ├── Attendance          (see 17_attendance.md)
           ├── Flashcards          (see 19_flashcards.md)
           └── Study sessions      (see 12_focus_mode.md)
```

## Subject model

```dart
class Subject {
  final int? id;
  final int? semesterId;            // FK to semesters.id
  final String name;                // required, e.g. "Operating System"
  final String? code;               // "CSE-321"
  final double? credit;             // 3.0
  final String? teacher;            // "Mr. Karim"
  final String color;               // "#4F46E5" — palette hex
  final double targetAttendance;    // default 75.0 percent
  final DateTime createdAt;

  Subject copyWith({...});
  Map<String, Object?> toMap();
  factory Subject.fromMap(Map<String, Object?> map);
}
```

## Semester model

```dart
class Semester {
  final int? id;
  final int? profileId;             // FK to profiles.id
  final String name;                // "Fall 2025" / "২০২৫ সেশন"
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;              // only one per profile
  final DateTime createdAt;
}
```

## Visual layout

The screen shows:

```
┌──────────────────────────────────────────┐
│ 📚 Subjects                       👤    │  ← profile icon → /profiles
├──────────────────────────────────────────┤
│ ┌─────────────────┐ ┌─────────────────┐ │
│ │ 🎓 SSC 2026     │ │ 📅 7th Sem ▼    │ │
│ │ School · Class 10│ │                 │ │
│ └─────────────────┘ └─────────────────┘ │
│                                          │
│ 📘 Operating System         [CSE-321]    │
│    3 credits                              │
│                                          │
│ 📗 Database Systems         [CSE-323]    │
│    3 credits                              │
│                                          │
│ 📙 Computer Networks                     │
│                                          │
│ 📕 Software Engineering      [CSE-401]    │
│                                          │
│ 📒 Mathematics                            │
│                                          │
│                            [ + Add ]     │  ← FAB
└──────────────────────────────────────────┘
```

### Context strip

Top of the screen, two pills:

- **Active profile pill** (left, tappable → `/profiles`)
  - Shows `Profile.name` + level + class
  - If no profile, shows "Set up profile"
- **Active semester pill** (right, tappable → `/semesters`)
  - Shows `Semester.name`
  - If no semester, shows "Semester" placeholder

### Subject card

```dart
class SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback? onTap;          // → /subjects/:id
  // ...
}
```

Layout:

- Color icon square (46×46, rounded 14px, color at 15% alpha background,
  solid color icon)
- Title (titleMedium)
- Code (bodySmall, optional)
- Credit badge (right, surfaceAlt background, "3 cr")

Icons are auto-detected from subject name:

| Substring                          | Icon                       |
| ---------------------------------- | -------------------------- |
| math / গণিত                          | Icons.calculate_rounded    |
| phys / পদার্থ                        | Icons.science_rounded      |
| chem / রসায়ন                        | Icons.biotech_rounded      |
| bio / জীব                           | Icons.eco_rounded          |
| eng / ইংরেজি                       | Icons.translate_rounded    |
| bangla / বাংলা                      | Icons.menu_book_rounded    |
| hist / ইতিহাস                       | Icons.history_edu_rounded  |
| ict / program                      | Icons.code_rounded         |
| _default_                          | Icons.menu_book_rounded    |

### Empty state

```
┌──────────────────────────────────────────┐
│                                          │
│              📚                          │
│                                          │
│         No subjects yet                  │
│                                          │
│  Add your first subject to start         │
│            tracking                      │
│                                          │
│       [   Add Subject   ]                │
│                                          │
└──────────────────────────────────────────┘
```

## Add subject form (`/subjects/add`)

Form fields:

| Field           | Type                       | Required |
| --------------- | -------------------------- | -------- |
| Subject name    | TextField                  | Yes      |
| Course code     | TextField                  | No       |
| Teacher         | TextField                  | No       |
| Credit          | TextField (number)         | No       |
| Color           | 8-swatch palette           | Default `#4F46E5` |

Color palette:

```
#4F46E5  Indigo
#0EA5E9  Sky
#16A34A  Green
#F59E0B  Amber
#DC2626  Red
#A855F7  Purple
#EC4899  Pink
#14B8A6  Teal
```

Form validation:

- `name` is required (`validator: required`).
- `credit` is parsed as `double`, allowed to be empty.
- On save, the subject is assigned to the **active semester** automatically.

## Files

```
lib/features/subjects/
├── models/
│   ├── subject.dart
│   ├── semester.dart
│   ├── topic.dart                    # (see 05_topic_status.md)
│   └── syllabus_item.dart            # (see 04_syllabus_tracker.md)
├── repositories/
│   └── subjects_repository.dart
├── view_models/
│   └── subjects_view_model.dart      # StateNotifier + bootstrap()
├── views/
│   ├── subjects_view.dart            # ConsumerStatefulWidget
│   ├── subject_add_view.dart         # ConsumerStatefulWidget
│   ├── subject_detail_view.dart      # (see 03_subject_details.md)
│   └── semesters_view.dart           # ConsumerStatefulWidget
└── widgets/
    ├── subject_card.dart
    └── subject_color_swatch.dart
```

## ViewModel API

```dart
class SubjectsState {
  final bool isLoading;
  final List<Semester> semesters;
  final List<Subject> subjects;
  final Semester? activeSemester;
}

class SubjectsViewModel extends StateNotifier<SubjectsState> {
  SubjectsViewModel(Ref ref);

  void bootstrap();                                    // async load on first frame
  Future<void> load();                                 // explicit refresh

  Future<void> addSemester(Semester s);
  Future<void> setActiveSemester(Semester s);

  Future<void> addSubject(Subject s);
  Future<void> updateSubject(Subject s);
  Future<void> deleteSubject(int id);

  // Topics
  Future<void> addTopic(Topic t);
  Future<void> updateTopic(Topic t);
  Future<void> deleteTopic(int id);
  Future<List<Topic>> getTopics(int subjectId);

  // Syllabus
  Future<void> addSyllabus(SyllabusItem item);
  Future<void> toggleSyllabus(SyllabusItem item);
  Future<void> deleteSyllabus(int id);
  Future<List<SyllabusItem>> getSyllabus(int subjectId);
}
```

### `load()` semantics

```dart
Future<void> load() async {
  state = state.copyWith(isLoading: true);
  final repo = _ref.read(subjectsRepositoryProvider);
  final semesters = await repo.getSemesters();
  Semester? active;
  for (final s in semesters) {
    if (s.isActive) {
      active = s;
      break;
    }
  }
  active ??= semesters.isEmpty ? null : semesters.first;
  final subjects = await repo.getSubjects(semesterId: active?.id);
  state = SubjectsState(
    isLoading: false,
    semesters: semesters,
    subjects: subjects,
    activeSemester: active,
  );
}
```

## Subjects repository

```dart
class SubjectsRepository {
  SubjectsRepository(this._db);

  final AppDatabase _db;

  Future<List<Semester>> getSemesters({int? profileId});
  Future<Semester?> getActiveSemester({int? profileId});
  Future<void> addSemester(Semester s);
  Future<void> setActiveSemester(int id);

  Future<List<Subject>> getSubjects({int? semesterId});
  Future<Subject?> getSubject(int id);
  Future<void> addSubject(Subject s);
  Future<void> updateSubject(Subject s);
  Future<void> deleteSubject(int id);

  // Topics
  Future<List<Topic>> getTopics(int subjectId);
  Future<void> addTopic(Topic t);
  Future<void> updateTopic(Topic t);
  Future<void> deleteTopic(int id);

  // Syllabus
  Future<List<SyllabusItem>> getSyllabus(int subjectId);
  Future<void> addSyllabus(SyllabusItem item);
  Future<void> updateSyllabus(SyllabusItem item);
  Future<void> deleteSyllabus(int id);
}
```

## Multi-profile, multi-semester

- A user can have multiple profiles (e.g. "SSC 2026" + "HSC Coaching").
- Each profile has many semesters.
- Only ONE semester is **active** at a time across the app.
- Switching active semester:
  1. Updates the `semesters.isActive` flag (set others to false).
  2. Reloads the subject list filtered by the new active semester.
  3. The Home Dashboard and other screens re-derive via Riverpod.

See `34_student_profile.md` and `33_bd_onboarding.md` for the broader
profile / semester model.

## Database

```sql
CREATE TABLE profiles (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  name         TEXT NOT NULL,
  level        TEXT NOT NULL,        -- 'school' | 'college' | 'university' | ...
  class_label  TEXT,
  institution  TEXT,
  department   TEXT,
  student_id   TEXT,
  created_at   TEXT NOT NULL
);

CREATE TABLE semesters (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  profile_id   INTEGER REFERENCES profiles(id) ON DELETE CASCADE,
  name         TEXT NOT NULL,
  start_date   TEXT,
  end_date     TEXT,
  is_active    INTEGER NOT NULL DEFAULT 0,
  created_at   TEXT NOT NULL
);

CREATE TABLE subjects (
  id                  INTEGER PRIMARY KEY AUTOINCREMENT,
  semester_id         INTEGER REFERENCES semesters(id) ON DELETE CASCADE,
  name                TEXT NOT NULL,
  code                TEXT,
  teacher             TEXT,
  credit              REAL,
  color               TEXT NOT NULL,
  target_attendance   REAL NOT NULL DEFAULT 75.0,
  created_at          TEXT NOT NULL
);
```

## Bangla strings

| English                | Bangla              |
| ---------------------- | ------------------- |
| Subjects               | বিষয়সমূহ            |
| Semester               | সেশন                |
| Profile                | প্রোফাইল            |
| Set up profile         | প্রোফাইল সেটআপ করো   |
| Add Subject            | বিষয় যোগ করো        |
| Add Semester           | সেশন যোগ করো         |
| Subject name           | বিষয়ের নাম           |
| Course code (optional) | কোর্স কোড (ঐচ্ছিক)    |
| Teacher (optional)     | শিক্ষক (ঐচ্ছিক)        |
| Credit (optional)      | ক্রেডিট (ঐচ্ছিক)      |
| Color                  | রঙ                  |
| Add                    | যোগ করুন             |
| No subjects yet        | কোনো বিষয় নেই         |
| Add your first subject | আপনার প্রথম বিষয় যোগ করুন |
| 3 credits              | ৩ ক্রেডিট              |

## Dark mode

- Subject card uses `ThemeColors.surface` (theme-aware).
- Icon background uses the subject's color at 15% alpha (works in both).
- Credit badge uses `ThemeColors.surfaceAlt`.
- Text: `AppTextStyles.titleMedium` (no hardcoded color).

## Performance

- Subject list is a `ListView.separated` with `physics:
  AlwaysScrollableScrollPhysics()` for refresh.
- Icons in `subject_card.dart` are computed via `Map<String, IconData>` for
  O(1) lookup.
- Avoid re-decoding the color hex on every build — cache by subject id.

## Edge cases

- **No profile yet** — context strip shows "Set up profile" pill; tapping
  it goes to `/profiles`.
- **No semester yet** — context strip shows "Semester" placeholder; tapping
  it goes to `/semesters`.
- **Subject with no code/credit** — fields hide gracefully.
- **Long subject name** — subject card title truncates with ellipsis.
- **Switching active semester** — preserves current scroll position; does
  not dispose the ViewModel.
- **Deleting active semester** — falls back to the next one if any, else
  to `null` (no subjects visible).
- **Subject added via Daily Add** — assigned to currently active semester.

## Riverpod rules

- `SubjectsView` is `ConsumerStatefulWidget`.
- `initState` schedules `bootstrap()` via `addPostFrameCallback`.
- `bootstrap()` is also called whenever the user changes the active
  semester or active profile.
- `SemestersView` and `SubjectsView` both bootstrap the same VM — Riverpod
  dedupes the load.

## Linked features

- **03 — Subject Details**: tap → opens the Subject Details hub.
- **04 — Syllabus Tracker**: syllabus tab inside Subject Details.
- **05 — Topic Status**: topics tab inside Subject Details.
- **17 — Attendance**: attendance tab inside Subject Details.
- **33 — BD Onboarding**: default semester + subject seeding.
- **34 — Student Profile**: profile is the parent of semester.

## Done criteria

- [ ] Can add, edit, delete a subject.
- [ ] Can switch active semester and the list updates.
- [ ] Empty state shows when no subjects.
- [ ] Subject color is preserved across app restarts.
- [ ] Tapping a subject opens `/subjects/:id`.
- [ ] FAB navigates to `/subjects/add`.
- [ ] No assertion errors on launch (Riverpod bootstrap pattern).
- [ ] Dark mode: subject card legible.
- [ ] Bangla: "বিষয়" renders correctly.
- [ ] Tests pass; `flutter analyze` clean.