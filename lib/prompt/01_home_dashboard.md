# 01 — Home Dashboard

The Home Dashboard is the **most important screen** in StudyBondhu. It is the
student's daily command center. The student opens the app and immediately
understands: **"আজ আমার কী করা উচিত?"** ("What should I do today?").

## Goals

- Communicate today's state at a glance: progress, streak, focus.
- Surface ONE primary recommendation: what to study now.
- Show today's tasks, upcoming exams, revision queue.
- Keep all data fresh via `HomeViewModel.bootstrap()`.
- Feel motivating, not punishing.

## Visual layout (top → bottom)

```
┌──────────────────────────────────────────┐
│ Good Morning 👋                          │
│ Monday, 17 August                        │
│ ──────────────────────────────────────── │
│ ┌──────────────────────────────────────┐ │
│ │ Today's progress              🔥 8d  │ │
│ │ 2h 15m / 3h                          │ │
│ │ ████████░░░ 75%                      │ │
│ │ 3 tasks completed                    │ │
│ └──────────────────────────────────────┘ │
│                                          │
│ ┌──────────────────────────────────────┐ │
│ │ 🎯 FOCUS NOW                         │ │
│ │ Recommended for you                  │ │
│ │                                      │ │
│ │ 🔴 Round Robin Scheduling            │ │
│ │ Subject: Operating System            │ │
│ │ Reason: Weak Topic                   │ │
│ │ Estimated: 30 minutes                │ │
│ │                                      │ │
│ │ [    Start Study    ]                │ │
│ └──────────────────────────────────────┘ │
│                                          │
│ 📝 Today's Tasks                  TODAY  │
│ ┌──────────────────────────────────────┐ │
│ │ 🔴 DBMS Assignment     Due tomorrow  │ │
│ │ 🟡 OS Revision         CPU Scheduling│ │
│ │ 🟢 Math Practice       20 minutes    │ │
│ └──────────────────────────────────────┘ │
│                                          │
│ 🧠 Revision Due                 TODAY    │
│ ┌──────────────────────────────────────┐ │
│ │ • FCFS Scheduling                    │ │
│ │ • Normalization                      │ │
│ │ • TCP/IP                             │ │
│ │                                      │ │
│ │ [ Start Revision ]                   │ │
│ └──────────────────────────────────────┘ │
│                                          │
│ 📅 Upcoming Exams                       │
│ ┌──────────────────────────────────────┐ │
│ │ Operating System    5 days left      │ │
│ │ Preparation: 72%                     │ │
│ │ [ View Preparation ]                 │ │
│ └──────────────────────────────────────┘ │
└──────────────────────────────────────────┘
```

Bangla variant:

```
┌──────────────────────────────────────────┐
│ শুভ সকাল 👋                              │
│ সোমবার, ১৭ আগস্ট                          │
│ ──────────────────────────────────────── │
│ আজকের অগ্রগতি                    🔥 ৮ দিন │
│ ২ ঘ ১৫ মি / ৩ ঘ                            │
│ ████████░░░ ৭৫%                           │
│ ৩টি কাজ সম্পন্ন                          │
│                                          │
│ 🎯 এখন ফোকাস করো                          │
│ আপনার জন্য সুপারিশ                       │
│                                          │
│ 🔴 Round Robin Scheduling                │
│ বিষয়: Operating System                  │
│ কারণ: দুর্বল বিষয়                        │
│ আনুমানিক: ৩০ মিনিট                       │
│                                          │
│ [    পড়া শুরু করো    ]                   │
└──────────────────────────────────────────┘
```

## Section breakdown

### 1. Greeting header

- Time-of-day greeting:
  - 5–11: "Good Morning" / "শুভ সকাল"
  - 12–16: "Good Afternoon" / "শুভ দুপুর"
  - 17–20: "Good Evening" / "শুভ সন্ধ্যা"
  - else: "Hello" / "নমস্কার"
- Date in locale-aware format.
- Optional name (from `Profile.name` if set).
- Bangla dates use `intl`'s Bengali locale.

### 2. Today's progress card

Shows:

- **Study time** = todaySeconds (from `StudySession.durationSeconds`)
- **Daily goal** = `settings.dailyGoalMinutes` (default 180 min)
- **Progress bar** = `(todaySeconds / 60) / dailyGoalMinutes`
- **Tasks completed** = count of assignments with `status == completed` and
  `dueDate == today`
- **Streak badge** = 🔥 + day count, accent color
- **Goal reached state**:
  - Below 100%: "75% of daily goal"
  - 100%: "🎉 Goal reached today — amazing!"

### 3. Focus Now card (primary CTA)

This is the **most important** widget on the screen. It must always render
ONE recommendation, even if the recommendation is "Study something light
today".

#### Recommendation algorithm (priority order)

1. **Upcoming exam's subject** — if any exam is within 14 days, recommend
   its subject. Reason: `Exam "OS Final" in 5 days`.
2. **Weak topic subject** — if any topic has `status == weak`, recommend
   that subject. Reason: `Weak topic: Round Robin`.
3. **Lowest study time this week** — sort subjects by last 7 days study
   seconds; recommend the lowest. Reason: `Lowest study time this week —
   focus here`.
4. **Default** — if no subjects / no data, hide the card with empty state.

```dart
StudyRecommendation? _buildRecommendation({
  required List<Subject> subjects,
  required List<Exam> upcomingExams,
  required Map<int, int> subjectSeconds,
  required List<RevisionItem> pendingRevisions,
}) {
  if (subjects.isEmpty) return null;
  // 1. Closest exam's subject
  if (upcomingExams.isNotEmpty) {
    final ex = upcomingExams.first;
    final subj = subjects.firstWhere(
      (s) => s.id == ex.subjectId,
      orElse: () => subjects.first,
    );
    final days = AppDateUtils.daysUntil(ex.examDate);
    return StudyRecommendation(
      subj,
      days <= 1
          ? 'Exam "${ex.title}" is $days day away'
          : 'Exam "${ex.title}" in $days days',
    );
  }
  // 2. Weak topics (when topic status is implemented)
  // 3. Lowest study time
  final sorted = [...subjects]..sort((a, b) =>
      (subjectSeconds[a.id] ?? 0).compareTo(subjectSeconds[a.id] ?? 0));
  return StudyRecommendation(
    sorted.first,
    'Lowest study time this week — focus here',
  );
}
```

#### Tap behavior

- "Start Study" → `/study` (opens Focus Mode with the subject pre-selected).

### 4. Today's Tasks section

- Filter: `assignments` where `status == pending` AND `dueDate == today`.
- Sort: by priority (high → low), then by due time.
- Top 3 shown; if more, "See all" → `/assignments`.
- Each row:
  - Color dot (priority: 🔴 high / 🟡 medium / 🟢 low)
  - Title
  - Subject (if any)
  - Due chip ("Due today", "Due tomorrow", "Due 20 Aug")

### 5. Revision Due section

- Filter: `revisionItems` where `status == pending` AND `scheduledDate ==
  today OR scheduledDate < today` (overdue included).
- Sort: by `scheduledDate` ascending.
- If empty, hide the entire section.
- "Start Revision" → opens the first revision card.

### 6. Upcoming Exams section

- Filter: `exams` where `examDate >= today`.
- Sort: by `examDate` ascending.
- Top 3; if more, "See all" → `/exams`.
- Each row:
  - Subject color band
  - Title + days-left chip ("5 days left", "Tomorrow")
  - Preparation progress bar (uses `09_exam_preparation.md` formula)

### 7. Empty state (overall)

If no subjects AND no assignments AND no exams AND no routines:

```
🌱

Add a subject, assignment, exam or routine
to get personalised recommendations.
```

This is shown only when ALL sections are empty.

## Files

```
lib/features/home/
├── view_models/
│   └── home_view_model.dart           # StateNotifier + bootstrap()
├── views/
│   └── home_view.dart                 # ConsumerStatefulWidget, top-level screen
└── widgets/
    ├── greeting_header.dart           # time-of-day + date
    ├── today_progress_card.dart       # study time + streak
    ├── study_recommendation_card.dart # 🔴 FOCUS NOW card
    ├── today_tasks_section.dart       # pending assignments today
    ├── revision_card.dart             # revision list
    ├── upcoming_exam_card.dart        # next 3 exams
    └── routine_card.dart              # today's routines strip
```

## Data flow

```
HomeView (ConsumerStatefulWidget)
   └── initState → bootstrap() postFrameCallback
        └── HomeViewModel.bootstrap() → Future.microtask(load)
             └── load() async {
                  await _ref.read(subjectsViewModelProvider.notifier).bootstrap();
                  await _ref.read(assignmentsViewModelProvider.notifier).bootstrap();
                  await _ref.read(examsViewModelProvider.notifier).bootstrap();
                  await _ref.read(revisionViewModelProvider.notifier).bootstrap();
                  await _ref.read(studyViewModelProvider.notifier).bootstrap();
                  await _ref.read(routinesViewModelProvider.notifier).bootstrap();
                  ...
                  state = HomeState(...);
                }
```

**Important:** the `bootstrap()` pattern is required for Home because it
chains multiple providers. See `architecture_riverpod.md`.

## State

```dart
class HomeState {
  final bool isLoading;
  final int todaySeconds;
  final int dailyGoalMinutes;
  final int streakDays;
  final List<Assignment> todayAssignments;
  final List<Exam> upcomingExams;
  final List<RevisionItem> pendingRevisions;
  final List<Routine> todaysRoutines;
  final StudyRecommendation? recommendation;
  final Map<int, int> subjectSeconds;   // last 7 days, by subjectId

  double get dailyProgress =>
      dailyGoalMinutes == 0 ? 0 : (todaySeconds / 60) / dailyGoalMinutes;
}

class StudyRecommendation {
  final Subject subject;
  final String reason;
  const StudyRecommendation(this.subject, this.reason);
}
```

## Bangla strings

| English                       | Bangla                   |
| ----------------------------- | ------------------------ |
| Today's progress              | আজকের অগ্রগতি               |
| Good Morning                  | শুভ সকাল                   |
| Good Afternoon                | শুভ দুপুর                   |
| Good Evening                  | শুভ সন্ধ্যা                 |
| Monday, 17 August             | সোমবার, ১৭ আগস্ট             |
| Focus Now                     | এখন ফোকাস করো               |
| Recommended for you           | আপনার জন্য সুপারিশ            |
| Start Study                   | পড়া শুরু করো                |
| Continue                      | চালিয়ে যাও                  |
| Today's Tasks                 | আজকের কাজ                 |
| Revision Due                  | আজ রিভিশন দিতে হবে            |
| Upcoming Exams                | আসছে পরীক্ষা                |
| Goal reached today — amazing! | আজকের লক্ষ্য পূরণ!            |
| Keep going!                   | চালিয়ে যাও!                 |
| 75% of daily goal             | দৈনিক লক্ষ্যের ৭৫%            |
| 3 tasks completed             | ৩টি কাজ সম্পন্ন              |
| Add a subject, assignment,    | বিষয়, অ্যাসাইনমেন্ট, পরীক্ষা বা  |
| exam or routine to get        | রুটিন যোগ করুন ব্যক্তিগত      |
| personalised recommendations | সুপারিশ পেতে                |

## Pull-to-refresh

The whole screen is wrapped in `RefreshIndicator`. On pull, it calls
`HomeViewModel.load()` which re-runs all the chained loads.

## Performance

- Each section only renders when its data is non-empty (early return).
- `ListView` with `physics: AlwaysScrollableScrollPhysics()` so the
  refresh indicator works even when content is short.
- Padding bottom 80px so content isn't hidden behind FAB.

## Dark mode

- All widgets use `ThemeColors` and `AppTextStyles` (no hardcoded colors).
- The streak chip uses `AppColors.accent` background.
- The Focus Now card uses a primary-color gradient (works in both modes).
- TextContrast: streak chip text is `textOnPrimary` on accent background.

## Edge cases

- **No internet** — Home has no network calls; works fully offline.
- **No data** — shows empty state CTA "Add a subject…".
- **App killed mid-session** — Home shows today's progress including any
  pre-kill sessions; no data loss.
- **Today's date changes while app is open** — Home doesn't auto-refresh
  the date; user pulls to refresh.
- **Long subject name** — Focus Now card truncates with ellipsis.

## Riverpod rules

- HomeView is `ConsumerStatefulWidget`.
- `initState` schedules `bootstrap()` via `addPostFrameCallback`.
- `HomeViewModel.bootstrap()` is the only entry point for initial load.
- `RefreshIndicator` calls `load()` directly (not bootstrap).

## Linked features

- **11 — What Should I Study Now**: the recommendation card surfaces the
  algorithm. The full plan lives in feature 11.
- **15 — Study Analytics**: the streak + total time feed Analytics.
- **23 — Study Streak**: the streak number is computed by
  `HomeViewModel._computeStreak()`.
- **20 — Bangla + English**: every static string has a Bangla equivalent.

## Done criteria

- [ ] No assertion errors on first launch.
- [ ] Dark mode: all text legible, no black-on-black.
- [ ] Pull-to-refresh reloads everything.
- [ ] Empty state appears for a brand-new install.
- [ ] Bangla greeting renders correctly.
- [ ] "Start Study" navigates to `/study` with subject pre-selected.
- [ ] Streak chip updates after a study session completes.
- [ ] Recommendation changes when an exam is within 14 days.
- [ ] Performance: Home rebuilds < 16ms on data change.
- [ ] All tests pass; `flutter analyze` is clean.