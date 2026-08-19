import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../models/study_session.dart';
import '../repositories/study_repository.dart' show DailyStudySummary;

class StudyState {
  final bool isLoading;
  final List<StudySession> sessions;
  final int todaySeconds;
  final List<DailyStudySummary> weekly;
  const StudyState({
    this.isLoading = false,
    this.sessions = const [],
    this.todaySeconds = 0,
    this.weekly = const [],
  });

  StudyState copyWith({
    bool? isLoading,
    List<StudySession>? sessions,
    int? todaySeconds,
    List<DailyStudySummary>? weekly,
  }) =>
      StudyState(
        isLoading: isLoading ?? this.isLoading,
        sessions: sessions ?? this.sessions,
        todaySeconds: todaySeconds ?? this.todaySeconds,
        weekly: weekly ?? this.weekly,
      );
}

class StudyViewModel extends StateNotifier<StudyState> {
  StudyViewModel(this._ref) : super(const StudyState());
  final Ref _ref;

  void bootstrap() {
    Future.microtask(load);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final repo = _ref.read(studyRepositoryProvider);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final sessions = await repo.getSessions();
    final todaySec = await repo
        .totalSecondsSince(start);
    final weekly = await repo.getDailyTotals(7);
    state = StudyState(
      isLoading: false,
      sessions: sessions,
      todaySeconds: todaySec,
      weekly: weekly,
    );
  }

  Future<void> addSession(StudySession s) async {
    await _ref.read(studyRepositoryProvider).addSession(s);
    await load();
  }

  Future<void> updateSession(StudySession s) async {
    await _ref.read(studyRepositoryProvider).updateSession(s);
    await load();
  }

  Future<void> deleteSession(int id) async {
    await _ref.read(studyRepositoryProvider).deleteSession(id);
    await load();
  }
}

final studyViewModelProvider =
    StateNotifierProvider<StudyViewModel, StudyState>(
  (ref) => StudyViewModel(ref),
);

// Timer (transient state)
class TimerState {
  final bool running;
  final bool paused;
  final Duration elapsed;
  final int? subjectId;
  final int? topicId;
  final StudyMode mode;
  final int focusTargetSec; // for pomodoro/focus reminder
  const TimerState({
    this.running = false,
    this.paused = false,
    this.elapsed = Duration.zero,
    this.subjectId,
    this.topicId,
    this.mode = StudyMode.focus,
    this.focusTargetSec = 25 * 60,
  });

  TimerState copyWith({
    bool? running,
    bool? paused,
    Duration? elapsed,
    int? subjectId,
    int? topicId,
    StudyMode? mode,
    int? focusTargetSec,
  }) =>
      TimerState(
        running: running ?? this.running,
        paused: paused ?? this.paused,
        elapsed: elapsed ?? this.elapsed,
        subjectId: subjectId ?? this.subjectId,
        topicId: topicId ?? this.topicId,
        mode: mode ?? this.mode,
        focusTargetSec: focusTargetSec ?? this.focusTargetSec,
      );
}

class TimerViewModel extends StateNotifier<TimerState> {
  TimerViewModel(this._ref) : super(const TimerState());

  final Ref _ref;
  DateTime? _startedAt;
  Duration _accumulated = Duration.zero;

  void start({
    int? subjectId,
    int? topicId,
    StudyMode mode = StudyMode.focus,
  }) {
    _startedAt = DateTime.now();
    _accumulated = Duration.zero;
    state = state.copyWith(
      running: true,
      paused: false,
      elapsed: Duration.zero,
      subjectId: subjectId,
      topicId: topicId,
      mode: mode,
    );
  }

  void tick() {
    if (!state.running || state.paused) return;
    final running = DateTime.now().difference(_startedAt ?? DateTime.now());
    state = state.copyWith(elapsed: _accumulated + running);
  }

  void pause() {
    if (!state.running || state.paused) return;
    final running = DateTime.now().difference(_startedAt ?? DateTime.now());
    _accumulated += running;
    state = state.copyWith(paused: true, elapsed: _accumulated);
  }

  void resume() {
    if (!state.running || !state.paused) return;
    _startedAt = DateTime.now();
    state = state.copyWith(paused: false);
  }

  Future<StudySession?> stop() async {
    if (!state.running) return null;
    final end = DateTime.now();
    final start = _startedAt ?? end;
    final total = _accumulated +
        (state.paused
            ? Duration.zero
            : DateTime.now().difference(start));
    state = TimerState(
      mode: state.mode,
      subjectId: state.subjectId,
      topicId: state.topicId,
      focusTargetSec: state.focusTargetSec,
    );
    if (total.inSeconds < 5) return null;
    final session = StudySession(
      subjectId: state.subjectId,
      topicId: state.topicId,
      startTime: start,
      endTime: end,
      durationSeconds: total.inSeconds,
      mode: state.mode,
      createdAt: DateTime.now(),
    );
    await _ref.read(studyViewModelProvider.notifier).addSession(session);
    return session;
  }

  void reset() {
    _startedAt = null;
    _accumulated = Duration.zero;
    state = const TimerState();
  }
}

final timerViewModelProvider =
    StateNotifierProvider<TimerViewModel, TimerState>(
  (ref) => TimerViewModel(ref),
);

/// When other screens (e.g. Subject Details "Start Study" CTA) want to
/// preselect a subject on the Study screen, they set this. The
/// TimerPanel consumes it on first build and clears it. Riverpod's
/// auto-dispose semantics mean a stale value never leaks across sessions.
final pendingStudySubjectIdProvider = StateProvider<int?>((_) => null);