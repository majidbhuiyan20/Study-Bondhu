import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/duration_utils.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../study/view_models/study_view_model.dart'
    show pendingStudySubjectIdProvider;
import '../models/subject.dart';
import '../models/syllabus_item.dart';
import '../view_models/subjects_view_model.dart';
import '../widgets/edit_subject_sheet.dart';
import '../widgets/subject_detail_header.dart';
import 'tabs/subject_assignments_view.dart';
import 'tabs/subject_attendance_view.dart';
import 'tabs/subject_detail_widgets.dart' show CascadeRow;
import 'tabs/subject_exams_view.dart';
import 'tabs/subject_notes_view.dart';
import 'tabs/subject_study_time_view.dart';
import 'tabs/subject_syllabus_view.dart';
import 'tabs/subject_topics_view.dart';
import 'tabs/subject_detail_widgets.dart'
    show AddTopicSheet, AddNoteSheet;

/// Spec 03 — Subject Details. Single screen with 7 tabs:
/// Syllabus, Topics, Assignments, Exams, Attendance, Study Time, Notes.
class SubjectDetailView extends ConsumerStatefulWidget {
  const SubjectDetailView({super.key, required this.subjectId});

  final int subjectId;

  @override
  ConsumerState<SubjectDetailView> createState() => _SubjectDetailViewState();
}

class _SubjectDetailViewState extends ConsumerState<SubjectDetailView> {
  @override
  void initState() {
    super.initState();
    // Invalidate family providers so we get fresh data on (re-)entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.invalidate(topicsForSubjectProvider(widget.subjectId));
      ref.invalidate(syllabusForSubjectProvider(widget.subjectId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Subject?>(
      future: ref.read(subjectsRepositoryProvider).getSubject(widget.subjectId),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: AppLoading());
        }
        final subject = snap.data;
        if (subject == null) {
          // Spec 03 §"Edge cases" — snackbar + pop.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(context.l10n.subjectNotFoundSnack)),
              );
              Navigator.pop(context);
            }
          });
          return Scaffold(
            appBar: AppBar(),
            body: AppEmptyState(
              title: context.l10n.subjectNotFoundSnack,
              icon: Icons.error_outline,
            ),
          );
        }
        return _DetailScaffold(subject: subject);
      },
    );
  }
}

class _DetailScaffold extends ConsumerStatefulWidget {
  const _DetailScaffold({required this.subject});
  final Subject subject;

  @override
  ConsumerState<_DetailScaffold> createState() => _DetailScaffoldState();
}

class _DetailScaffoldState extends ConsumerState<_DetailScaffold> {
  @override
  Widget build(BuildContext context) {
    final subject = widget.subject;
    final l10n = context.l10n;
    final syllabusAsync =
        ref.watch(syllabusForSubjectProvider(subject.id!));
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: Text(subject.name, overflow: TextOverflow.ellipsis),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (v) async {
                if (v == 'edit') {
                  await EditSubjectSheet.show(context, existing: subject);
                  ref.invalidate(syllabusForSubjectProvider(subject.id!));
                } else if (v == 'delete') {
                  await _showDeleteCascadeDialog(context, ref, subject);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    const Icon(Icons.edit_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.editSubject),
                  ]),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    const Icon(Icons.delete_outline,
                        size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(l10n.deleteSubject,
                        style: const TextStyle(color: Colors.red)),
                  ]),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l10n.tabSyllabus),
              Tab(text: l10n.tabTopics),
              Tab(text: l10n.tabAssignments),
              Tab(text: l10n.tabExams),
              Tab(text: l10n.tabAttendance),
              Tab(text: l10n.tabStudyTime),
              Tab(text: l10n.tabNotes),
            ],
          ),
        ),
        floatingActionButton: _SubjectDetailFab(subject: subject),
        body: Column(
          children: [
            syllabusAsync.maybeWhen(
              data: (items) => SubjectDetailHeader(
                subject: subject,
                syllabus: items,
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            Expanded(
              child: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  SubjectSyllabusView(
                    subjectId: subject.id!,
                    onAdd: () =>
                        _showAddSyllabusSheet(context, ref, subject.id!),
                  ),
                  SubjectTopicsView(subjectId: subject.id!),
                  SubjectAssignmentsView(subjectId: subject.id!),
                  SubjectExamsView(subjectId: subject.id!),
                  SubjectAttendanceView(subjectId: subject.id!),
                  SubjectStudyTimeView(subjectId: subject.id!),
                  SubjectNotesView(subjectId: subject.id!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Spec 03 §"Delete subject" — dialog with per-table counts.
  Future<void> _showDeleteCascadeDialog(
      BuildContext context, WidgetRef ref, Subject subject) async {
    final l10n = context.l10n;
    final db = ref.read(subjectsRepositoryProvider);
    final subjId = subject.id!;

    final syllabus = await db.getSyllabus(subjId);
    final topics = await db.getTopics(subjId);
    final assignments = await ref
        .read(assignmentsRepositoryProvider)
        .getAssignments(subjectId: subjId);
    final exams = await ref
        .read(examsRepositoryProvider)
        .getExams(subjectId: subjId);
    final notes = await ref
        .read(notesRepositoryProvider)
        .getNotes(subjectId: subjId);
    final attendance = await ref
        .read(attendanceRepositoryProvider)
        .getAttendanceForSubject(subjId);
    final sessions = await ref
        .read(studyRepositoryProvider)
        .getSessions(subjectId: subjId);
    final sessionSeconds =
        sessions.fold<int>(0, (a, b) => a + b.durationSeconds);

    if (!context.mounted) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${l10n.deleteSubject} "${subject.name}"?'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.deleteSubjectWarning,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              CascadeRow(
                  icon: Icons.list_alt,
                  label: l10n.syllabusLabel,
                  count: syllabus.length),
              CascadeRow(
                  icon: Icons.checklist,
                  label: l10n.topicsLabel,
                  count: topics.length),
              CascadeRow(
                  icon: Icons.assignment_outlined,
                  label: l10n.assignments,
                  count: assignments.length),
              CascadeRow(
                  icon: Icons.event_note_outlined,
                  label: l10n.exams,
                  count: exams.length),
              CascadeRow(
                  icon: Icons.event_available_outlined,
                  label: l10n.attendance,
                  count: attendance.length),
              CascadeRow(
                  icon: Icons.timer_outlined,
                  label: '${l10n.sessionsLabel} (${_fmt(sessionSeconds)})',
                  count: sessions.length),
              CascadeRow(
                  icon: Icons.note_alt_outlined,
                  label: l10n.notesLabel,
                  count: notes.length),
              const SizedBox(height: 8),
              Text(l10n.cannotBeUndone,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref
          .read(subjectsViewModelProvider.notifier)
          .deleteSubject(subjId);
      if (context.mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context);
      }
    }
  }

  String _fmt(int sec) =>
      DurationUtils.formatHuman(Duration(seconds: sec));

  void _showAddSyllabusSheet(
      BuildContext context, WidgetRef ref, int subjectId) {
    final l10n = context.l10n;
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSt) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.syllabusAdd, style: AppTextStyles.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: l10n.title,
                  hintText: l10n.syllabusRename,
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  hintText: '${l10n.description} (optional)',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.cancel),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () async {
                      if (titleCtrl.text.trim().isEmpty) return;
                      final next = await ref
                          .read(subjectsRepositoryProvider)
                          .getSyllabus(subjectId);
                      await ref
                          .read(subjectsViewModelProvider.notifier)
                          .addSyllabus(SyllabusItem(
                            subjectId: subjectId,
                            title: titleCtrl.text.trim(),
                            description: descCtrl.text.trim().isEmpty
                                ? null
                                : descCtrl.text.trim(),
                            orderIndex: next.length,
                            createdAt: DateTime.now(),
                          ));
                      ref.invalidate(
                          syllabusForSubjectProvider(subjectId));
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// FAB
// ---------------------------------------------------------------------

/// FAB swaps between "Add topic" / "New note" / "Start study" depending
/// on the active tab (spec 03).
class _SubjectDetailFab extends ConsumerWidget {
  const _SubjectDetailFab({required this.subject});
  final Subject subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (ctx, _) {
        final idx = controller.index;
        // 1 = topics, 6 = notes → contextual FABs
        // everything else → Start study (since this screen is the
        // study entry point for the subject)
        IconData icon;
        String label;
        VoidCallback onTap;
        switch (idx) {
          case 1:
            icon = Icons.checklist_rounded;
            label = l10n.addTopic;
            onTap = () {
              showModalBottomSheet<void>(
                context: ctx,
                isScrollControlled: true,
                builder: (c) => AddTopicSheet(subjectId: subject.id!),
              );
            };
            break;
          case 6:
            icon = Icons.note_add_outlined;
            label = l10n.addNewNote;
            onTap = () {
              showModalBottomSheet<void>(
                context: ctx,
                isScrollControlled: true,
                builder: (c) => AddNoteSheet(subjectId: subject.id!),
              );
            };
            break;
          default:
            icon = Icons.play_arrow_rounded;
            label = l10n.startStudyCta;
            onTap = () {
              // Pre-select this subject for the timer.
              ref
                  .read(pendingStudySubjectIdProvider.notifier)
                  .state = subject.id;
              context.go(AppRoutes.study);
            };
        }
        return FloatingActionButton.extended(
          heroTag: 'fab-subject-detail-${subject.id ?? 'new'}',
          onPressed: onTap,
          icon: Icon(icon),
          label: Text(label),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
        );
      },
    );
  }
}

// Inline aliases removed — sheets imported directly from
// subject_detail_widgets.dart.
