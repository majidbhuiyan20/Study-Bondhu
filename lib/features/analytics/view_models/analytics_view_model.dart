import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../settings/view_models/settings_view_model.dart';
import '../../study/repositories/study_repository.dart' show DailyStudySummary;
import '../../subjects/models/topic.dart';
import '../models/goal.dart';

/// Derived insights (spec #15) — friendly roll-ups of "what the data is
/// telling you" surfaced between the weekly chart and the weakness radar.
class AnalyticsInsights {
  /// Subject id with the most study seconds in the last 7 days, or null.
  final int? mostStudiedSubjectId;
  final int mostStudiedSeconds;

  /// Subject id with the least study seconds (among subjects that have at
  /// least one study session), or null.
  final int? leastStudiedSubjectId;
  final int leastStudiedSeconds;

  /// `DateTime.weekday` of the day that had the most study totals in the
  /// last 7 days, or null if nothing was studied.
  final int? mostProductiveWeekday;
  final int mostProductiveSeconds;

  /// Total number of topics marked as "completed" across all subjects.
  final int completedTopics;

  /// Total number of revision items logged.
  final int revisionCount;

  const AnalyticsInsights({
    this.mostStudiedSubjectId,
    this.mostStudiedSeconds = 0,
    this.leastStudiedSubjectId,
    this.leastStudiedSeconds = 0,
    this.mostProductiveWeekday,
    this.mostProductiveSeconds = 0,
    this.completedTopics = 0,
    this.revisionCount = 0,
  });

  bool get isEmpty =>
      mostStudiedSubjectId == null &&
      mostProductiveWeekday == null &&
      completedTopics == 0 &&
      revisionCount == 0;
}

class AnalyticsState {
  final bool isLoading;
  final List<DailyStudySummary> weekly;
  final Map<int, int> subjectSecondsLast7Days;
  final List<Goal> goals;
  final int totalSessions;
  final int totalSeconds;
  final double avgFocus;
  final int streakDays;
  final AnalyticsInsights insights;

  const AnalyticsState({
    this.isLoading = false,
    this.weekly = const [],
    this.subjectSecondsLast7Days = const {},
    this.goals = const [],
    this.totalSessions = 0,
    this.totalSeconds = 0,
    this.avgFocus = 0,
    this.streakDays = 0,
    this.insights = const AnalyticsInsights(),
  });

  AnalyticsState copyWith({
    bool? isLoading,
    List<DailyStudySummary>? weekly,
    Map<int, int>? subjectSecondsLast7Days,
    List<Goal>? goals,
    int? totalSessions,
    int? totalSeconds,
    double? avgFocus,
    int? streakDays,
    AnalyticsInsights? insights,
  }) =>
      AnalyticsState(
        isLoading: isLoading ?? this.isLoading,
        weekly: weekly ?? this.weekly,
        subjectSecondsLast7Days:
            subjectSecondsLast7Days ?? this.subjectSecondsLast7Days,
        goals: goals ?? this.goals,
        totalSessions: totalSessions ?? this.totalSessions,
        totalSeconds: totalSeconds ?? this.totalSeconds,
        avgFocus: avgFocus ?? this.avgFocus,
        streakDays: streakDays ?? this.streakDays,
        insights: insights ?? this.insights,
      );
}

class AnalyticsViewModel extends StateNotifier<AnalyticsState> {
  AnalyticsViewModel(this._ref) : super(const AnalyticsState());
  final Ref _ref;

  void bootstrap() {
    Future.microtask(load);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final studyRepo = _ref.read(studyRepositoryProvider);
    final now = DateTime.now();
    final weekly = await studyRepo.getDailyTotals(7);
    final last7Start = now.subtract(const Duration(days: 7));
    final bySubject = await studyRepo.totalSecondsBySubjectSince(last7Start);
    final allSessions = await studyRepo.getSessions();
    final totalSec =
        allSessions.fold<int>(0, (acc, s) => acc + s.durationSeconds);
    final avgFocus = allSessions.isEmpty
        ? 0.0
        : allSessions.map((s) => s.focusRating).reduce((a, b) => a + b) /
            allSessions.length;

    final goals = await _ref.read(analyticsRepositoryProvider).getGoals();

    int streak = 0;
    final goalMin = _ref.read(settingsViewModelProvider).dailyGoalMinutes;
    final thresholdSec =
        Duration(minutes: goalMin.clamp(1, 1440)).inSeconds;
    for (int i = weekly.length - 1; i >= 0; i--) {
      if (weekly[i].seconds >= thresholdSec) {
        streak++;
      } else if (i == weekly.length - 1) {
        continue;
      } else {
        break;
      }
    }

    // Derived insights (spec #15): most/least studied subject, most
    // productive weekday, completed topics, revision count.
    int? mostId;
    int mostSec = 0;
    int? leastId;
    int leastSec = -1; // -1 sentinel: "haven't found a non-zero yet"
    bySubject.forEach((id, sec) {
      if (sec > mostSec) {
        mostSec = sec;
        mostId = id;
      }
      if (sec > 0 && (leastSec < 0 || sec < leastSec)) {
        leastSec = sec;
        leastId = id;
      }
    });

    int? bestWeekday;
    int bestWeekdaySec = 0;
    for (final d in weekly) {
      if (d.seconds > bestWeekdaySec) {
        bestWeekdaySec = d.seconds;
        bestWeekday = d.date.weekday;
      }
    }

    final topicsRepo = _ref.read(subjectsRepositoryProvider);
    final revisionRepo = _ref.read(revisionRepositoryProvider);
    final allTopics = await topicsRepo.getAllTopics();
    final completed = allTopics
        .where((t) => t.status == TopicStatus.mastered)
        .length;
    final revisions = await revisionRepo.getAll();

    state = state.copyWith(
      isLoading: false,
      weekly: weekly,
      subjectSecondsLast7Days: bySubject,
      goals: goals,
      totalSessions: allSessions.length,
      totalSeconds: totalSec,
      avgFocus: avgFocus,
      streakDays: streak,
      insights: AnalyticsInsights(
        mostStudiedSubjectId: mostId,
        mostStudiedSeconds: mostSec,
        leastStudiedSubjectId: leastId,
        leastStudiedSeconds: leastSec < 0 ? 0 : leastSec,
        mostProductiveWeekday: bestWeekday,
        mostProductiveSeconds: bestWeekdaySec,
        completedTopics: completed,
        revisionCount: revisions.length,
      ),
    );
  }

  Future<void> addGoal(Goal g) async {
    await _ref.read(analyticsRepositoryProvider).addGoal(g);
    await load();
  }

  Future<void> deleteGoal(int id) async {
    await _ref.read(analyticsRepositoryProvider).deleteGoal(id);
    await load();
  }
}

final analyticsViewModelProvider =
    StateNotifierProvider<AnalyticsViewModel, AnalyticsState>(
  (ref) => AnalyticsViewModel(ref),
);