import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/duration_utils.dart';
import '../../subjects/models/topic.dart';
import '../../subjects/view_models/subjects_view_model.dart';
import '../../revision/models/revision_item.dart';
import '../models/study_session.dart';
import '../view_models/study_view_model.dart';
import 'session_complete_sheet.dart';

class TimerPanel extends ConsumerStatefulWidget {
  const TimerPanel({super.key});

  @override
  ConsumerState<TimerPanel> createState() => _TimerPanelState();
}

class _TimerPanelState extends ConsumerState<TimerPanel> {
  int? _subjectId;
  StudyMode _mode = StudyMode.focus;
  bool _showSubjectMissingError = false;

  @override
  void initState() {
    super.initState();
    _tick();
    // Honor preselected subject (e.g. from Subject Details "Start study").
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final pending = ref.read(pendingStudySubjectIdProvider);
      if (pending != null) {
        setState(() => _subjectId = pending);
        ref.read(pendingStudySubjectIdProvider.notifier).state = null;
      }
    });
  }

  void _tick() async {
    while (mounted) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) break;
      ref.read(timerViewModelProvider.notifier).tick();
    }
  }

  Future<void> _start() async {
    // Defense in depth: the Start button is disabled when _subjectId is
    // null, but if it's somehow tapped (focus traversal, accessibility),
    // we exit silently rather than starting a session with no subject.
    if (_subjectId == null) {
      setState(() => _showSubjectMissingError = true);
      return;
    }
    try {
      ref.read(timerViewModelProvider.notifier).start(
            subjectId: _subjectId,
            mode: _mode,
          );
    } on ArgumentError {
      // The VM rejected the call — surface the same inline error.
      if (!mounted) return;
      setState(() => _showSubjectMissingError = true);
      return;
    }
    setState(() => _showSubjectMissingError = false);
    setState(() {});
  }

  Future<void> _stop() async {
    final session = await ref.read(timerViewModelProvider.notifier).stop();
    if (!mounted) return;
    // Clear local picker so next session starts fresh.
    setState(() {
      _subjectId = null;
      _mode = StudyMode.focus;
    });
    if (session != null) {
      // Build the topic list for this subject (if any) so the user can
      // tag the session with a specific topic (spec 13).
      List<({int id, String name})> topics = const [];
      final subjectId = session.subjectId;
      if (subjectId != null) {
        final allTopics = await ref
            .read(subjectsRepositoryProvider)
            .getTopics(subjectId);
        topics = allTopics
            .map((t) => (id: t.id!, name: t.name))
            .toList(growable: false);
      }
      // Compute today's running total so the sheet can show "Today's
      // Study: …" (spec 13 §"UI").
      final today = await _todaySeconds();
      if (!mounted) return;

      final rated = await SessionCompleteSheet.show(
        context: context,
        session: session,
        dailyTotalSec: today,
        topics: topics,
      );
      if (rated != null && mounted) {
        await ref
            .read(studyViewModelProvider.notifier)
            .updateSession(session.copyWith(
              notes: rated.notes,
              focusRating: rated.rating,
              topicId: rated.topicId,
            ));
        // Spec 13 §"Topic.status update": weak → weak, strong → mastered.
        if (rated.topicId != null) {
          await _updateTopicStatus(rated.topicId!, rated.rating);
        }
        // Spec 10 — schedule the next revision based on rating.
        await _scheduleNextRevision(session, rated.rating, rated.topicId);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Saved ${DurationUtils.formatHms(session.duration)} session'),
        ),
      );
    }
  }

  Future<int> _todaySeconds() async {
    final now = DateTime.now();
    final start = now.subtract(Duration(hours: now.hour));
    return ref
        .read(studyRepositoryProvider)
        .totalSecondsBySubjectSince(start)
        .then((m) => m.values.fold<int>(0, (a, b) => a + b));
  }

  Future<void> _updateTopicStatus(int topicId, int rating) async {
    final all = await ref.read(subjectsRepositoryProvider).getAllTopics();
    Topic? found;
    for (final t in all) {
      if (t.id == topicId) {
        found = t;
        break;
      }
    }
    if (found == null) return;
    // Spec 10 — Topic.status update:
    //   weak → weak, strong → mastered, okay → unchanged.
    final next = switch (rating) {
      1 => TopicStatus.weak,
      5 => TopicStatus.mastered,
      _ => found.status, // okay: leave as-is
    };
    await ref.read(subjectsViewModelProvider.notifier).updateTopic(
          found.copyWith(
            status: next,
            confidence: rating,
            isCompleted: rating == 5,
          ),
        );
  }

  Future<void> _scheduleNextRevision(
    StudySession session,
    int rating,
    int? topicId,
  ) async {
    // Spec 10: Day 1 / Day 3 / Day 7 / Day 14 / Day 30 spaced cycle.
    // Interval doubles on Strong, halves on Weak, stays the same on Okay.
    // For the *first* session (no prior interval), seed with the canonical
    // Day-1 / Day-3 / Day-7 baseline.
    final priorInterval = session.focusRating == 0
        ? 0
        : (switch (session.focusRating) {
            1 => 1,
            5 => 7,
            _ => 3,
          });
    int newInterval;
    if (priorInterval <= 0) {
      newInterval = switch (rating) {
        1 => 1,
        5 => 7,
        _ => 3,
      };
    } else {
      newInterval = switch (rating) {
        1 => (priorInterval ~/ 2).clamp(1, 30),
        5 => (priorInterval * 2).clamp(1, 30),
        _ => priorInterval.clamp(1, 30),
      };
    }
    final next = AppDateUtils.morningOf(
      DateTime.now().add(Duration(days: newInterval)),
    );
    await ref.read(revisionRepositoryProvider).addRevision(
          RevisionItem(
            subjectId: session.subjectId,
            topicId: topicId,
            scheduledDate: next,
            status: RevisionStatus.pending,
            intervalDays: newInterval,
            createdAt: DateTime.now(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(timerViewModelProvider);
    final subjectsAsync = ref.watch(_subjectsProvider);
    final isRunning = timer.running;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardFill =
        isRunning ? AppColors.primarySoft : Theme.of(context).cardColor;
    final cardBorder = isRunning
        ? AppColors.primaryLight
        : (isDark ? AppColors.darkBorder : AppColors.border);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cardBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRunning
                      ? (timer.paused
                          ? AppColors.warning
                          : AppColors.success)
                      : ThemeColors.textTertiary(context),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timer.running
                    ? (timer.paused ? 'Paused' : 'Studying')
                    : 'Ready to focus',
                style: AppTextStyles.label,
              ),
              const Spacer(),
              if (isRunning)
                Text(
                  _modeLabel(timer.mode),
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            DurationUtils.formatHms(timer.elapsed),
            style: AppTextStyles.numericHuge.copyWith(
              color: isRunning
                  ? AppColors.primary
                  : ThemeColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          if (!timer.running) ...[
            SegmentedButton<StudyMode>(
              segments: const [
                ButtonSegment(
                    value: StudyMode.focus, label: Text('Focus')),
                ButtonSegment(
                    value: StudyMode.pomodoro,
                    label: Text('Pomo')),
                ButtonSegment(
                    value: StudyMode.free, label: Text('Free')),
              ],
              selected: {_mode},
              onSelectionChanged: (s) =>
                  setState(() => _mode = s.first),
            ),
            const SizedBox(height: 12),
            subjectsAsync.when(
              data: (subjects) {
                if (subjects.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.warning, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Add a subject before starting a session.',
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              context.push(AppRoutes.subjectAdd),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<int?>(
                      // value must match the selected item; using null
                      // initially so Flutter shows the hint until the user
                      // picks one.
                      initialValue: _subjectId,
                      decoration: InputDecoration(
                        hintText: 'Pick a subject',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        errorText: _showSubjectMissingError
                            ? 'Please pick a subject to start studying'
                            : null,
                      ),
                      items: subjects
                          .map((s) => DropdownMenuItem<int?>(
                                value: s.id,
                                child: Text(s.name),
                              ))
                          .toList(growable: false),
                      onChanged: (v) {
                        setState(() {
                          _subjectId = v;
                          _showSubjectMissingError = false;
                        });
                      },
                    ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _subjectId == null ? null : _start,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start session'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: timer.paused
                        ? () => ref
                            .read(timerViewModelProvider.notifier)
                            .resume()
                        : () => ref
                            .read(timerViewModelProvider.notifier)
                            .pause(),
                    icon: Icon(timer.paused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded),
                    label: Text(timer.paused ? 'Resume' : 'Pause'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _stop,
                    icon: const Icon(Icons.stop_rounded),
                    label: const Text('Stop & save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _modeLabel(StudyMode mode) {
    switch (mode) {
      case StudyMode.focus:
        return 'FOCUS';
      case StudyMode.pomodoro:
        return 'POMODORO';
      case StudyMode.free:
        return 'FREE';
    }
  }
}

final _subjectsProvider = FutureProvider((ref) async {
  return ref.watch(subjectsRepositoryProvider).getSubjects();
});