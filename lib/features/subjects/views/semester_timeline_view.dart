import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla,AppLocalizationsCamelCase;
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../assignments/models/assignment.dart';
import '../../exams/models/exam.dart';
import '../../exams/views/exam_preparation_view.dart';
import '../models/semester.dart';
import '../view_models/subjects_view_model.dart';

/// One event on the timeline. Holds a date and a category label so we
/// can colour-code chips consistently.
class TimelineEvent {
  final DateTime date;
  final TimelineCategory category;
  final String title;
  final String? subtitle;
  final int? id; // optional, for navigation
  final TimelineTarget target;

  const TimelineEvent({
    required this.date,
    required this.category,
    required this.title,
    this.subtitle,
    this.id,
    this.target = TimelineTarget.none,
  });
}

enum TimelineCategory {
  classSession,
  assignmentCat,
  midterm,
  finalExam,
  presentation,
  labExam,
  quiz,
  other,
}

enum TimelineTarget {
  none,
  assignmentT,
  examT,
}

extension TimelineCategoryX on TimelineCategory {
  Color get color {
    switch (this) {
      case TimelineCategory.classSession:
        return AppColors.info;
      case TimelineCategory.assignmentCat:
        return AppColors.warning;
      case TimelineCategory.midterm:
        return AppColors.error;
      case TimelineCategory.finalExam:
        return AppColors.accent;
      case TimelineCategory.presentation:
        return AppColors.primary;
      case TimelineCategory.labExam:
        return AppColors.success;
      case TimelineCategory.quiz:
        return const Color(0xFF8B5CF6);
      case TimelineCategory.other:
        return const Color(0xFF9CA3AF);
    }
  }

  IconData get icon {
    switch (this) {
      case TimelineCategory.classSession:
        return Icons.school_rounded;
      case TimelineCategory.assignmentCat:
        return Icons.assignment_rounded;
      case TimelineCategory.midterm:
        return Icons.menu_book_rounded;
      case TimelineCategory.finalExam:
        return Icons.workspace_premium_rounded;
      case TimelineCategory.presentation:
        return Icons.slideshow_rounded;
      case TimelineCategory.labExam:
        return Icons.science_rounded;
      case TimelineCategory.quiz:
        return Icons.quiz_rounded;
      case TimelineCategory.other:
        return Icons.event_rounded;
    }
  }

  String enLabel() {
    switch (this) {
      case TimelineCategory.classSession:
        return 'Classes';
      case TimelineCategory.assignmentCat:
        return 'Assignment';
      case TimelineCategory.midterm:
        return 'Midterm';
      case TimelineCategory.finalExam:
        return 'Final Exam';
      case TimelineCategory.presentation:
        return 'Presentation';
      case TimelineCategory.labExam:
        return 'Lab Exam';
      case TimelineCategory.quiz:
        return 'Quiz';
      case TimelineCategory.other:
        return 'Event';
    }
  }

  String bnLabel() {
    switch (this) {
      case TimelineCategory.classSession:
        return 'ক্লাস';
      case TimelineCategory.assignmentCat:
        return 'অ্যাসাইনমেন্ট';
      case TimelineCategory.midterm:
        return 'মিডটার্ম';
      case TimelineCategory.finalExam:
        return 'ফাইনাল';
      case TimelineCategory.presentation:
        return 'প্রেজেন্টেশন';
      case TimelineCategory.labExam:
        return 'ল্যাব পরীক্ষা';
      case TimelineCategory.quiz:
        return 'কুইজ';
      case TimelineCategory.other:
        return 'ইভেন্ট';
    }
  }
}

final timelineProvider = FutureProvider.family
    .autoDispose<List<TimelineEvent>, int?>((ref, semesterId) async {
  final assignmentsRepo = ref.watch(assignmentsRepositoryProvider);
  final examsRepo = ref.watch(examsRepositoryProvider);
  final routinesRepo = ref.watch(routinesRepositoryProvider);
  final subjectsRepo = ref.watch(subjectsRepositoryProvider);

  final allSubjects = await subjectsRepo.getSubjects();
  final subjectById = {
    for (final s in allSubjects)
      if (s.id != null) s.id!: s.name,
  };

  final List<TimelineEvent> events = [];

  // ----- Assignments -----
  final assignments = await assignmentsRepo.getAssignments();
  for (final a in assignments) {
    if (a.dueDate == null) continue;
    if (a.status == AssignmentStatus.completed) continue;
    events.add(TimelineEvent(
      date: a.dueDate!,
      category: TimelineCategory.assignmentCat,
      title: a.title,
      subtitle: a.subjectId == null ? null : subjectById[a.subjectId],
      id: a.id,
      target: TimelineTarget.assignmentT,
    ));
  }

  // ----- Exams -----
  final exams = await examsRepo.getExams();
  for (final e in exams) {
    events.add(TimelineEvent(
      date: e.examDate,
      category: _mapExamType(e.type),
      title: e.title,
      subtitle: e.subjectId == null ? null : subjectById[e.subjectId],
      id: e.id,
      target: TimelineTarget.examT,
    ));
  }

  // ----- Routines (collapse into "Classes" chips) -----
  final allRoutines = await routinesRepo.getRoutines();
  final semester = semesterId == null
      ? null
      : (await subjectsRepo.getSemesters())
          .where((s) => s.id == semesterId)
          .cast<Semester?>()
          .firstWhere((_) => true, orElse: () => null);
  final start = semester?.startDate ??
      DateTime.now().subtract(const Duration(days: 7));
  final end = semester?.endDate ??
      DateTime.now().add(const Duration(days: 180));
  for (final r in allRoutines) {
    if (!r.isActive) continue;
    if (r.daysOfWeek.isEmpty) continue;
    var cursor = _firstOnOrAfter(start, r.daysOfWeek);
    while (!cursor.isAfter(end)) {
      events.add(TimelineEvent(
        date: cursor,
        category: TimelineCategory.classSession,
        title: r.title,
        subtitle: r.timeOfDay,
        target: TimelineTarget.none,
      ));
      cursor = _nextOnOrAfter(
        cursor.add(const Duration(days: 1)),
        r.daysOfWeek,
      );
    }
  }

  events.sort((a, b) => a.date.compareTo(b.date));
  return events;
});

TimelineCategory _mapExamType(ExamType t) {
  switch (t) {
    case ExamType.midterm:
      return TimelineCategory.midterm;
    case ExamType.finalExam:
      return TimelineCategory.finalExam;
    case ExamType.quiz:
      return TimelineCategory.quiz;
    case ExamType.other:
      return TimelineCategory.other;
  }
}

DateTime _firstOnOrAfter(DateTime from, List<int> weekdays) {
  final stripped = DateTime(from.year, from.month, from.day);
  for (var i = 0; i < 7; i++) {
    final candidate = stripped.add(Duration(days: i));
    if (weekdays.contains(candidate.weekday)) return candidate;
  }
  return stripped;
}

DateTime _nextOnOrAfter(DateTime from, List<int> weekdays) {
  return _firstOnOrAfter(from, weekdays);
}

final _semesterProvider = FutureProvider.autoDispose<Semester?>(
  (ref) async {
    final state = ref.watch(subjectsViewModelProvider);
    final active = state.activeSemester;
    if (active != null) return active;
    final list = await ref.watch(subjectsRepositoryProvider).getSemesters();
    if (list.isEmpty) return null;
    return list.first;
  },
);

class SemesterTimelineView extends ConsumerWidget {
  const SemesterTimelineView({
    super.key,
    this.semesterId,
  });
  final int? semesterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final resolvedId = semesterId ??
        ref.watch(_semesterProvider).valueOrNull?.id;
    final eventsAsync = ref.watch(timelineProvider(resolvedId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.semesterTimeline)),
      body: eventsAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (events) {
          if (events.isEmpty) {
            return AppEmptyState(
              title: l10n.semesterTimelineEmpty,
              message: l10n.semesterTimelineHint,
              icon: Icons.timeline_outlined,
            );
          }
          return _buildTimeline(context, events);
        },
      ),
    );
  }

  Widget _buildTimeline(
    BuildContext context,
    List<TimelineEvent> events,
  ) {
    final months = <String, List<TimelineEvent>>{};
    for (final e in events) {
      final key = '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}';
      months.putIfAbsent(key, () => []).add(e);
    }
    final monthKeys = months.keys.toList()..sort();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: monthKeys.length,
      itemBuilder: (ctx, i) {
        final key = monthKeys[i];
        final monthEvents = months[key]!;
        final monthLabel = du.AppDateUtils.formatDate(
          monthEvents.first.date,
          pattern: 'MMMM y',
        );
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                monthLabel,
                style: AppTextStyles.titleLarge.copyWith(
                  color: ThemeColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 12),
              for (final e in monthEvents) _TimelineRow(event: e),
            ],
          ),
        );
      },
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.event});
  final TimelineEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _open(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 56,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${event.date.day}',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    du.AppDateUtils.formatWeekday(event.date),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: ThemeColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 2,
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              color: event.category.color.withValues(alpha: 0.5),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: event.category.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: event.category.color.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      event.category.icon,
                      size: 16,
                      color: event.category.color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            [
                              l10n.isBangla
                                  ? event.category.bnLabel()
                                  : event.category.enLabel(),
                              if (event.subtitle != null) event.subtitle!,
                            ].join(' • '),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: ThemeColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    switch (event.target) {
      case TimelineTarget.examT:
        if (event.id != null) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ExamPreparationView(examId: event.id!),
          ));
        }
        break;
      case TimelineTarget.assignmentT:
        context.go(AppRoutes.assignments);
        break;
      case TimelineTarget.none:
        break;
    }
  }
}