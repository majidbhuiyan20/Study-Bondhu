import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../assignments/models/assignment.dart';
import '../../assignments/view_models/assignments_view_model.dart';
import '../../exams/models/exam.dart';
import '../../exams/view_models/exams_view_model.dart';
import '../../revision/models/revision_item.dart';
import '../../revision/view_models/revision_view_model.dart';
import '../../routines/models/routine.dart';
import '../../routines/view_models/routines_view_model.dart';
import '../../study/view_models/study_view_model.dart';
import '../../subjects/models/subject.dart';
import '../../subjects/models/topic.dart';
import '../../subjects/view_models/subjects_view_model.dart';
import '../../settings/view_models/settings_view_model.dart';

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
  final Map<int, int> subjectSeconds;
  final int weakTopicCount;

  const HomeState({
    this.isLoading = false,
    this.todaySeconds = 0,
    this.dailyGoalMinutes = 180,
    this.streakDays = 0,
    this.todayAssignments = const [],
    this.upcomingExams = const [],
    this.pendingRevisions = const [],
    this.todaysRoutines = const [],
    this.recommendation,
    this.subjectSeconds = const {},
    this.weakTopicCount = 0,
  });

  double get dailyProgress {
    if (dailyGoalMinutes == 0) return 0;
    return (todaySeconds / 60) / dailyGoalMinutes;
  }

  HomeState copyWith({
    bool? isLoading,
    int? todaySeconds,
    int? dailyGoalMinutes,
    int? streakDays,
    List<Assignment>? todayAssignments,
    List<Exam>? upcomingExams,
    List<RevisionItem>? pendingRevisions,
    List<Routine>? todaysRoutines,
    StudyRecommendation? recommendation,
    Map<int, int>? subjectSeconds,
    int? weakTopicCount,
  }) =>
      HomeState(
        isLoading: isLoading ?? this.isLoading,
        todaySeconds: todaySeconds ?? this.todaySeconds,
        dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
        streakDays: streakDays ?? this.streakDays,
        todayAssignments: todayAssignments ?? this.todayAssignments,
        upcomingExams: upcomingExams ?? this.upcomingExams,
        pendingRevisions: pendingRevisions ?? this.pendingRevisions,
        todaysRoutines: todaysRoutines ?? this.todaysRoutines,
        recommendation: recommendation ?? this.recommendation,
        subjectSeconds: subjectSeconds ?? this.subjectSeconds,
        weakTopicCount: weakTopicCount ?? this.weakTopicCount,
      );
}

class StudyRecommendation {
  final Subject subject;
  final String reason;
  const StudyRecommendation(this.subject, this.reason);
}

/// One line of the multi-item "What should I study now?" plan
/// (spec 11). [icon] is a code used by the card to colour the bullet.
class PlanItem {
  final String label;
  final int minutes;
  final int subjectId;
  final String icon; // 'weak' | 'revision' | 'assignment' | 'syllabus' | 'goal'
  const PlanItem({
    required this.label,
    required this.minutes,
    required this.subjectId,
    required this.icon,
  });
}

/// Aggregate of all plan items generated for a given time budget.
class StudyPlan {
  final int totalMinutes;
  final List<PlanItem> items;
  const StudyPlan({required this.totalMinutes, required this.items});

  bool get isEmpty => items.isEmpty;
}

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel(this._ref) : super(const HomeState());
  final Ref _ref;

  /// Call from the view after first frame to avoid nested provider
  /// initialization (Riverpod forbids providers from mutating other
  /// providers synchronously during their own construction).
  void bootstrap() {
    Future.microtask(load);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    // Trigger other loaders
    await _ref.read(subjectsViewModelProvider.notifier).load();
    await _ref.read(assignmentsViewModelProvider.notifier).load();
    await _ref.read(examsViewModelProvider.notifier).load();
    await _ref.read(revisionViewModelProvider.notifier).load();
    await _ref.read(studyViewModelProvider.notifier).load();
    await _ref.read(routinesViewModelProvider.notifier).load();

    final subjects = _ref.read(subjectsViewModelProvider).subjects;
    final dailyGoal = _ref.read(settingsViewModelProvider).dailyGoalMinutes;
    final today = DateTime.now();
    final startToday = DateTime(today.year, today.month, today.day);
    final sessions = _ref.read(studyViewModelProvider).sessions;
    final todaySec = sessions
        .where((s) => s.startTime.isAfter(startToday))
        .fold<int>(0, (acc, s) => acc + s.durationSeconds);

    final subjectSeconds = await _ref
        .read(studyRepositoryProvider)
        .totalSecondsBySubjectSince(
          startToday.subtract(const Duration(days: 7)),
        );

    final todayAssignments = _ref
        .read(assignmentsViewModelProvider)
        .assignments
        .where((a) =>
            a.status == AssignmentStatus.pending &&
            a.dueDate != null &&
            du.AppDateUtils.isSameDay(a.dueDate!, today))
        .toList();

    final upcoming = _ref
        .read(examsViewModelProvider)
        .exams
        .where((e) =>
            !e.examDate.isBefore(DateTime(today.year, today.month, today.day)))
        .toList()
      ..sort((a, b) => a.examDate.compareTo(b.examDate));

    final pendingRevisions = _ref
        .read(revisionViewModelProvider)
        .items
        .where((r) => r.status == RevisionStatus.pending)
        .toList();

    final streak = await _computeStreak();

    final weakTopics = await _loadWeakTopics(subjects);

    final recommendation = _buildRecommendation(
      subjects: subjects,
      upcomingExams: upcoming.take(3).toList(),
      subjectSeconds: subjectSeconds,
      pendingRevisions: pendingRevisions,
      weakTopics: weakTopics,
    );

    state = state.copyWith(
      isLoading: false,
      todaySeconds: todaySec,
      dailyGoalMinutes: dailyGoal,
      streakDays: streak,
      todayAssignments: todayAssignments,
      upcomingExams: upcoming.take(3).toList(),
      pendingRevisions: pendingRevisions.take(5).toList(),
      todaysRoutines:
          _ref.read(routinesViewModelProvider).todaysRoutines,
      recommendation: recommendation,
      subjectSeconds: subjectSeconds,
      weakTopicCount: weakTopics.length,
    );
  }

  Future<int> _computeStreak() async {
    final summaries = await _ref
        .read(studyRepositoryProvider)
        .getDailyTotals(60);
    // Spec 23: a day counts toward the streak if it hit the daily goal,
    // not just 60 seconds. Fall back to a small floor so a brand-new
    // install with very low goals still surfaces a streak.
    final goalMin = _ref.read(settingsViewModelProvider).dailyGoalMinutes;
    final threshold = Duration(minutes: goalMin.clamp(1, 1440));
    int streak = 0;
    for (int i = summaries.length - 1; i >= 0; i--) {
      if (summaries[i].seconds >= threshold.inSeconds) {
        streak++;
      } else if (i == summaries.length - 1) {
        // today not yet met — don't break streak
        continue;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Loads all topics across visible subjects and returns only the
  /// weak ones (confidence ≤ 2 and not completed). Spec: weak topic
  /// subject is the second-priority recommendation.
  Future<List<Topic>> _loadWeakTopics(List<Subject> subjects) async {
    final repo = _ref.read(subjectsRepositoryProvider);
    final all = <Topic>[];
    for (final s in subjects) {
      if (s.id == null) continue;
      final topics = await repo.getTopics(s.id!);
      all.addAll(topics);
    }
    return all
        .where((t) => !t.isCompleted && t.confidence <= 2)
        .toList();
  }

  // -----------------------------------------------------------------
  // Spec 11 — multi-item "What should I study now?" plan generator.
  // -----------------------------------------------------------------

  /// Builds a prioritized multi-item plan that fits in [minutes].
  Future<StudyPlan> buildPlan(int minutes) async {
    final subjects = _ref.read(subjectsViewModelProvider).subjects;
    if (subjects.isEmpty) {
      return StudyPlan(totalMinutes: minutes, items: const []);
    }
    final today = DateTime.now();
    final startToday =
        DateTime(today.year, today.month, today.day);

    // 1) Pull signals.
    final upcoming = _ref
        .read(examsViewModelProvider)
        .exams
        .where((e) => !e.examDate.isBefore(startToday))
        .toList()
      ..sort((a, b) => a.examDate.compareTo(b.examDate));
    final pendingRevisions = _ref
        .read(revisionViewModelProvider)
        .items
        .where((r) => r.status == RevisionStatus.pending)
        .toList();
    final weakTopics = await _loadWeakTopics(subjects);
    final pendingAssignments = _ref
        .read(assignmentsViewModelProvider)
        .assignments
        .where((a) =>
            a.status == AssignmentStatus.pending && a.dueDate != null)
        .toList();
    final sessionRepo = _ref.read(studyRepositoryProvider);
    final secondsBySubject = await sessionRepo
        .totalSecondsBySubjectSince(startToday);

    // 2) Score each subject (spec algorithm).
    final scores = <int, double>{};
    final byId = {for (final s in subjects) s.id: s};
    // Exam urgency (inverse of days_until).
    for (final ex in upcoming) {
      if (ex.subjectId == null) continue;
      final days = ex.examDate.difference(startToday).inDays;
      final urgency = days <= 0 ? 4.0 : 4.0 / (days + 1);
      scores[ex.subjectId!] = (scores[ex.subjectId!] ?? 0) + urgency * 4;
    }
    // Weak topic count.
    for (final t in weakTopics) {
      scores[t.subjectId] = (scores[t.subjectId] ?? 0) + 3;
    }
    // Revisions due.
    for (final r in pendingRevisions) {
      if (r.subjectId == null) continue;
      scores[r.subjectId!] = (scores[r.subjectId!] ?? 0) + 3;
    }
    // Assignment urgency (1-2 day window gets 2; others nothing).
    for (final a in pendingAssignments) {
      if (a.subjectId == null || a.dueDate == null) continue;
      final days = a.dueDate!.difference(startToday).inDays;
      if (days >= 0 && days <= 2) {
        scores[a.subjectId!] = (scores[a.subjectId!] ?? 0) + 2;
      }
    }
    // Goal gap — boost the lowest-studied subject.
    if (subjects.any((s) => secondsBySubject[s.id] == null)) {
      final minSec = secondsBySubject.values.fold<int>(
          1 << 30, (a, b) => a < b ? a : b);
      for (final s in subjects) {
        if ((secondsBySubject[s.id] ?? 0) <= minSec) {
          scores[s.id!] = (scores[s.id!] ?? 0) + 2;
        }
      }
    }

    // 3) Pick top subject.
    final topId = scores.entries.isEmpty
        ? subjects.first.id!
        : (scores.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key;
    final topSubject = byId[topId] ?? subjects.first;

    // 4) Allocate minutes. Reserve 25 min for top subject (weak topic),
    // split remainder across revisions + assignments + remaining time.
    final items = <PlanItem>[];
    int remaining = minutes;
    // Top subject: weak topic or general study.
    if (weakTopics.any((t) => t.subjectId == topId)) {
      final weak = weakTopics.firstWhere((t) => t.subjectId == topId);
      final m = remaining >= 25 ? 25 : remaining;
      items.add(PlanItem(
        label: '${weak.name} (Weak Topic)',
        minutes: m,
        subjectId: topId,
        icon: 'weak',
      ));
      remaining -= m;
    } else {
      final m = remaining >= 25 ? 25 : remaining;
      items.add(PlanItem(
        label: topSubject.name,
        minutes: m,
        subjectId: topId,
        icon: 'goal',
      ));
      remaining -= m;
    }

    // Pending revisions: 10 min each, until time runs out.
    for (final r
        in pendingRevisions.where((r) => r.subjectId != null)) {
      if (remaining < 10) break;
      items.add(PlanItem(
        label: 'Revision · ${byId[r.subjectId]?.name ?? 'Topic'}',
        minutes: 10,
        subjectId: r.subjectId!,
        icon: 'revision',
      ));
      remaining -= 10;
    }

    // Assignment in next 1-2 days: 10 min if available.
    final urgentAssignments = pendingAssignments
        .where((a) =>
            a.subjectId != null &&
            a.dueDate != null &&
            a.dueDate!.difference(startToday).inDays >= 0 &&
            a.dueDate!.difference(startToday).inDays <= 2)
        .toList();
    if (urgentAssignments.isNotEmpty && remaining >= 10) {
      final a = urgentAssignments.first;
      items.add(PlanItem(
        label: 'Assignment · ${a.title}',
        minutes: 10,
        subjectId: a.subjectId!,
        icon: 'assignment',
      ));
      remaining -= 10;
    }

    // Cap the plan at 3 items per spec example.
    final capped = items.take(3).toList();
    final totalAssigned = capped.fold<int>(0, (a, b) => a + b.minutes);
    return StudyPlan(totalMinutes: totalAssigned, items: capped);
  }

  StudyRecommendation? _buildRecommendation({
    required List<Subject> subjects,
    required List<Exam> upcomingExams,
    required Map<int, int> subjectSeconds,
    required List<RevisionItem> pendingRevisions,
    required List<Topic> weakTopics,
  }) {
    return computeRecommendation(
      subjects: subjects,
      upcomingExams: upcomingExams,
      subjectSeconds: subjectSeconds,
      pendingRevisions: pendingRevisions,
      weakTopics: weakTopics,
    );
  }

  /// Pure recommendation algorithm exposed for unit tests.
  static StudyRecommendation? computeRecommendation({
    required List<Subject> subjects,
    required List<Exam> upcomingExams,
    required Map<int, int> subjectSeconds,
    required List<RevisionItem> pendingRevisions,
    required List<Topic> weakTopics,
  }) {
    if (subjects.isEmpty) return null;
    // Priority 1: closest exam within 14 days.
    final nearExams = upcomingExams.where((e) {
      final days = du.AppDateUtils.daysUntil(e.examDate);
      return days <= 14;
    }).toList();

    if (nearExams.isNotEmpty) {
      final ex = nearExams.first;
      final subj = subjects.firstWhere(
        (s) => s.id == ex.subjectId,
        orElse: () => subjects.first,
      );
      final days = du.AppDateUtils.daysUntil(ex.examDate);
      final reason = days <= 1
          ? 'Exam "${ex.title}" is $days day away'
          : 'Exam "${ex.title}" in $days days';
      return StudyRecommendation(subj, reason);
    }
    // Priority 2: a subject with a weak topic.
    if (weakTopics.isNotEmpty) {
      final weak = weakTopics.first;
      final subj = subjects.firstWhere(
        (s) => s.id == weak.subjectId,
        orElse: () => subjects.first,
      );
      return StudyRecommendation(
        subj,
        'Weak topic: ${weak.name}',
      );
    }
    // Priority 3: subject with least study time in last 7 days.
    final sorted = [...subjects]..sort((a, b) =>
        (subjectSeconds[a.id] ?? 0).compareTo(subjectSeconds[b.id] ?? 0));
    final least = sorted.first;
    return StudyRecommendation(
      least,
      'Lowest study time this week — focus here',
    );
  }
}

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeState>(
  (ref) => HomeViewModel(ref),
);

/// Spec 11 — multi-item plan for the given time budget (minutes).
/// Defaults to 45 if the user hasn't picked one.
final studyPlanProvider =
    FutureProvider.autoDispose.family<StudyPlan, int>(
  (ref, minutes) async {
    return ref.read(homeViewModelProvider.notifier).buildPlan(minutes);
  },
);