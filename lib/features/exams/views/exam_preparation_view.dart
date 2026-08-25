import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX, AppLocalizationsBangla, AppLocalizationsCamelCase;
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../revision/models/revision_item.dart';
import '../../subjects/models/subject.dart';
import '../../subjects/models/syllabus_item.dart';
import '../../subjects/models/topic.dart';
import '../models/exam.dart';
import '../view_models/exams_view_model.dart';
import 'exam_add_view.dart';

/// A single recommended task on the exam-prep page.
/// The patient plan is sorted by urgency (weak topics first, then revision
/// items soonest, then completed study time).
class ExamPrepTask {
  final String title;
  final int minutes;
  final IconData icon;
  final Color color;
  final String? subtitle;
  const ExamPrepTask({
    required this.title,
    required this.minutes,
    required this.icon,
    required this.color,
    this.subtitle,
  });
}

class ExamReadiness {
  final double syllabusPct; // 0..1
  final double revisionPct; // 0..1
  final double studyPct; // 0..1
  final double practicePct; // 0..1
  final List<Topic> weakTopics;
  final List<ExamPrepTask> recommended;

  const ExamReadiness({
    required this.syllabusPct,
    required this.revisionPct,
    required this.studyPct,
    required this.practicePct,
    required this.weakTopics,
    required this.recommended,
  });

  /// Weighted formula from spec 09:
  ///   0.4 syllabus + 0.3 revision + 0.2 study + 0.1 practice.
  double get overall =>
      syllabusPct * 0.4 +
      revisionPct * 0.3 +
      studyPct * 0.2 +
      practicePct * 0.1;
}

final examReadinessProvider = FutureProvider.family
    .autoDispose<ExamReadiness, int>((ref, examId) async {
  final exam =
      await ref.watch(examsRepositoryProvider).getExam(examId);
  if (exam == null) {
    return const ExamReadiness(
      syllabusPct: 0,
      revisionPct: 0,
      studyPct: 0,
      practicePct: 0,
      weakTopics: [],
      recommended: [],
    );
  }
  final subjectId = exam.subjectId;
  if (subjectId == null) {
    return const ExamReadiness(
      syllabusPct: 0,
      revisionPct: 0,
      studyPct: 0,
      practicePct: 0,
      weakTopics: [],
      recommended: [],
    );
  }

  // ----- Syllabus -----
  final syllabus = await ref
      .watch(subjectsRepositoryProvider)
      .getSyllabus(subjectId);
  final syllabusPct = _syllabusFraction(syllabus);

  // ----- Topics + Weak -----
  final topics =
      await ref.watch(subjectsRepositoryProvider).getTopics(subjectId);
  final weakTopics = <Topic>[];
  for (final t in topics) {
    if (t.status == TopicStatus.weak) {
      weakTopics.add(t);
    }
  }
  // Sort weak topics by id (proxy for "last revision") — least recent first.
  // We don't have a last_revised_at column on topics, so id ordering is the
  // canonical "older topics surface first" heuristic.
  weakTopics.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));

  // ----- Revision -----
  final revisions = await ref.watch(revisionRepositoryProvider).getAll();
  final subjectRevisions = revisions
      .where((r) => r.subjectId == subjectId)
      .toList(growable: false);
  final revisionPct = _revisionFraction(subjectRevisions);

  // ----- Study time (over the last 7 days) -----
  final since = DateTime.now().subtract(const Duration(days: 7));
  final bySubject = await ref
      .watch(studyRepositoryProvider)
      .totalSecondsBySubjectSince(since);
  final studySec = bySubject[subjectId] ?? 0;
  // Map 0..7h (420 min) to 0..1. 7h/week ≈ 1h/day is the bar.
  final studyPct = (studySec / (7 * 3600)).clamp(0.0, 1.0).toDouble();

  // ----- Practice (assignments completed for this subject) -----
  final assignments =
      await ref.watch(assignmentsRepositoryProvider).getAssignments(
            subjectId: subjectId,
          );
  final completedAssignments =
      assignments.where((a) => a.status.name == 'completed').length;
  final practicePct = assignments.isEmpty
      ? 0.0
      : (completedAssignments / assignments.length).clamp(0.0, 1.0).toDouble();

  // ----- Recommended plan -----
  final recommended = <ExamPrepTask>[];
  // 1) Weak topics first — 40 min each (spec 09 example).
  for (final t in weakTopics.take(3)) {
    recommended.add(ExamPrepTask(
      title: t.name,
      minutes: 40,
      icon: Icons.priority_high_rounded,
      color: AppColors.error,
      subtitle: 'weak',
    ));
  }
  // 2) Soonest due revisions (next 7 days).
  final now = DateTime.now();
  final weekFromNow = now.add(const Duration(days: 7));
  final dueSoon = subjectRevisions
      .where((r) =>
          r.status == RevisionStatus.pending &&
          !r.scheduledDate.isBefore(now) &&
          r.scheduledDate.isBefore(weekFromNow))
      .toList()
    ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  for (final r in dueSoon.take(3)) {
    final topicName = r.topicId == null
        ? 'General revision'
        : (topics
            .where((t) => t.id == r.topicId)
            .map((t) => t.name)
            .firstOrNull ?? 'Revision');
    recommended.add(ExamPrepTask(
      title: topicName,
      subtitle: 'review',
      minutes: 25,
      icon: Icons.refresh_rounded,
      color: AppColors.primary,
    ));
  }
  // 3) Top uncompleted syllabus items for this subject.
  final remainingSyllabus = syllabus.where((s) => !s.isDone).toList();
  for (final s in remainingSyllabus.take(2)) {
    recommended.add(ExamPrepTask(
      title: s.title,
      subtitle: 'syllabus',
      minutes: 15,
      icon: Icons.menu_book_rounded,
      color: AppColors.success,
    ));
  }

  return ExamReadiness(
    syllabusPct: syllabusPct,
    revisionPct: revisionPct,
    studyPct: studyPct,
    practicePct: practicePct,
    weakTopics: weakTopics,
    recommended: recommended,
  );
});

double _syllabusFraction(List<SyllabusItem> items) {
  if (items.isEmpty) return 0.0;
  final done = items.where((s) => s.isDone).length;
  return (done / items.length).clamp(0.0, 1.0).toDouble();
}

double _revisionFraction(List<RevisionItem> items) {
  if (items.isEmpty) return 0.0;
  final completedOrFuture = items.where((r) =>
      r.status == RevisionStatus.completed ||
      r.scheduledDate.isAfter(DateTime.now())).length;
  return (completedOrFuture / items.length).clamp(0.0, 1.0).toDouble();
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

class ExamPreparationView extends ConsumerWidget {
  const ExamPreparationView({super.key, required this.examId});

  final int examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final examAsync = ref.watch(_examProvider(examId));
    final readinessAsync = ref.watch(examReadinessProvider(examId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.examPreparationTitle),
        actions: [
          if (examAsync.value != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.edit,
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ExamAddView(existing: examAsync.value!),
                  ),
                );
                ref.invalidate(_examProvider(examId));
                ref.invalidate(examReadinessProvider(examId));
                ref.read(examsViewModelProvider.notifier).load();
              },
            ),
        ],
      ),
      body: examAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (exam) {
          if (exam == null) {
            return Center(
              child: Text(l10n.examPreparationTitle),
            );
          }
          final subjectAsync = exam.subjectId == null
              ? const AsyncValue<Subject?>.data(null)
              : ref.watch(_subjectProvider(exam.subjectId!));
          final subject = subjectAsync.value;
          return readinessAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (r) => _Body(
              exam: exam,
              subject: subject,
              readiness: r,
            ),
          );
        },
      ),
    );
  }
}

final _examProvider =
    FutureProvider.family.autoDispose<Exam?, int>((ref, id) async {
  return ref.watch(examsRepositoryProvider).getExam(id);
});

final _subjectProvider =
    FutureProvider.family.autoDispose<Subject?, int>((ref, id) async {
  return ref.watch(subjectsRepositoryProvider).getSubject(id);
});

class _Body extends StatelessWidget {
  const _Body({
    required this.exam,
    required this.subject,
    required this.readiness,
  });

  final Exam exam;
  final Subject? subject;
  final ExamReadiness readiness;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final daysLeft = du.AppDateUtils.daysUntil(exam.examDate);
    final daysLabel = switch (daysLeft) {
      0 => l10n.examToday,
      1 => l10n.examTomorrow,
      < 0 => (l10n.isBangla ? 'পরীক্ষা শেষ হয়েছে' : 'Exam completed'),
      _ => '$daysLeft ${l10n.examDaysLeft}',
    };
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // ----- Header -----
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exam.title,
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: 4),
              if (subject != null)
                Text(
                  subject!.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: ThemeColors.textSecondary(context),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    daysLeft <= 3
                        ? Icons.timer_outlined
                        : Icons.calendar_today_outlined,
                    size: 18,
                    color: daysLeft <= 3
                        ? AppColors.error
                        : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    daysLabel,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: daysLeft <= 3
                          ? AppColors.error
                          : ThemeColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (exam.time != null || exam.location != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    if (exam.time != null)
                      _MetaPill(
                        icon: Icons.schedule_rounded,
                        label: exam.time!,
                      ),
                    if (exam.location != null)
                      _MetaPill(
                        icon: Icons.location_on_outlined,
                        label: exam.location!,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ----- Readiness bars -----
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReadinessRow(
                label: l10n.readinessSyllabus,
                value: readiness.syllabusPct,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              _ReadinessRow(
                label: l10n.readinessRevision,
                value: readiness.revisionPct,
                color: AppColors.accent,
              ),
              const SizedBox(height: 12),
              _ReadinessRow(
                label: l10n.readinessStudy,
                value: readiness.studyPct,
                color: AppColors.success,
              ),
              const SizedBox(height: 12),
              _ReadinessRow(
                label: l10n.readinessPractice,
                value: readiness.practicePct,
                color: AppColors.warning,
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _ReadinessRow(
                label: l10n.readinessOverall,
                value: readiness.overall,
                color: ThemeColors.textPrimary(context),
                bold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ----- Weak Topics -----
        Text(l10n.weakTopicsSection, style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        if (readiness.weakTopics.isEmpty)
          AppCard(
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    color: AppColors.success),
                const SizedBox(width: 10),
                Expanded(child: Text(l10n.noWeakTopics)),
              ],
            ),
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < readiness.weakTopics.length; i++) ...[
                  _WeakTopicTile(topic: readiness.weakTopics[i]),
                  if (i < readiness.weakTopics.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              ],
            ),
          ),
        const SizedBox(height: 16),

        // ----- Recommended Today -----
        Text(l10n.recommendedToday, style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        if (readiness.recommended.isEmpty)
          AppCard(
            child: Text(
              l10n.noWeakTopics,
              style: AppTextStyles.bodyMedium.copyWith(
                color: ThemeColors.textSecondary(context),
              ),
            ),
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < readiness.recommended.length; i++) ...[
                  _TaskTile(task: readiness.recommended[i]),
                  if (i < readiness.recommended.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ThemeColors.surfaceAlt(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: ThemeColors.textSecondary(context)),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _ReadinessRow extends StatelessWidget {
  const _ReadinessRow({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });
  final String label;
  final double value;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).round();
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: bold
                ? AppTextStyles.titleSmall
                : AppTextStyles.bodyMedium.copyWith(
                    color: ThemeColors.textSecondary(context),
                  ),
          ),
        ),
        Expanded(
          child: AppProgressBar(value: value, color: color, height: 8),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '$pct%',
            textAlign: TextAlign.right,
            style: bold
                ? AppTextStyles.titleSmall
                : AppTextStyles.bodyMedium.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: ThemeColors.textSecondary(context),
                  ),
          ),
        ),
      ],
    );
  }
}

class _WeakTopicTile extends StatelessWidget {
  const _WeakTopicTile({required this.topic});
  final Topic topic;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.error_outline, color: AppColors.error),
      title: Text(topic.name),
      subtitle: Text(
        topic.status.en,
        style: AppTextStyles.bodySmall.copyWith(
          color: ThemeColors.textSecondary(context),
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task});
  final ExamPrepTask task;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      leading: Icon(task.icon, color: task.color),
      title: Text(task.title),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: task.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '${task.minutes} ${l10n.minutesShort}',
          style: AppTextStyles.bodySmall.copyWith(
            color: task.color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
