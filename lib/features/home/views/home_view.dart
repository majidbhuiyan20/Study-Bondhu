import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n.dart'
    show
        AppLocalizationsBangla,
        AppLocalizationsCamelCase,
        AppLocalizationsX;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/quick_add_sheet.dart';
import '../../assignments/view_models/assignments_view_model.dart';
import '../../profile/view_models/profile_view_model.dart';
import '../../settings/view_models/settings_view_model.dart';
import '../view_models/home_view_model.dart';
import '../widgets/greeting_header.dart';
import '../widgets/quick_stats_row.dart';
import '../widgets/recent_activity_strip.dart';
import '../widgets/routine_card.dart';
import '../widgets/today_progress_card.dart';
import '../widgets/today_tasks_section.dart';
import '../widgets/upcoming_exam_card.dart';
import '../widgets/revision_card.dart';
import '../widgets/study_recommendation_card.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();
    // Defer initial load until after the first frame so this provider
    // isn't mutating other providers during its own construction.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeViewModelProvider.notifier).bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(homeViewModelProvider);
    final settings = ref.watch(settingsViewModelProvider);
    final profile = ref.watch(profileViewModelProvider).active;
    final isBangla = l10n.isBangla;

    // Quick stats: derive weak topic count by checking each subject.
    final upcomingAssignments =
        ref.watch(upcomingAssignmentsProvider).length;
    final todayMinutes = state.todaySeconds ~/ 60;

    final activity = _buildRecentActivity(
      state: state,
      isBangla: isBangla,
      l10n: l10n,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: l10n.drawerMenu,
            // `ctx` lives below this inner Scaffold, so
            // `Scaffold.of(ctx)` returns this widget (which has no
            // drawer). The outer Scaffold (in MainShell) that owns the
            // AppDrawer is an *ancestor* of this widget — call
            // `Scaffold.of` on `context` (the build method's context,
            // captured before this inner Scaffold was built).
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_rounded),
            tooltip: l10n.profileChip,
            onPressed: () => context.push(AppRoutes.profile),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab-home',
        onPressed: () => QuickAddSheet.show(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () =>
              ref.read(homeViewModelProvider.notifier).load(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              GreetingHeader(
                name: profile?.name.isNotEmpty == true
                    ? profile!.name
                    : (settings.locale.languageCode == 'bn'
                        ? 'বন্ধু'
                        : 'Bondhu'),
                avatarPath: profile?.avatarPath,
                onAvatarTap: () => context.push(AppRoutes.profile),
              ),
              const SizedBox(height: 18),
              QuickStatsRow(
                minutesToday: todayMinutes,
                assignmentsDue: upcomingAssignments,
                weakTopicCount: state.weakTopicCount,
                streakDays: state.streakDays,
              ),
              const SizedBox(height: 18),
              TodayProgressCard(state: state),
              if (activity.isNotEmpty) ...[
                const SizedBox(height: 18),
                RecentActivityStrip(items: activity),
              ],
              const SizedBox(height: 22),
              const StudyRecommendationCard(),
              const SizedBox(height: 22),
              RoutinesHomeSection(routines: state.todaysRoutines),
              if (state.todaysRoutines.isNotEmpty)
                const SizedBox(height: 22),
              _SectionTitle(title: l10n.todayTasks),
              const SizedBox(height: 8),
              TodayTasksSection(tasks: state.todayAssignments),
              const SizedBox(height: 22),
              _SectionTitle(title: l10n.upcomingExams),
              const SizedBox(height: 8),
              UpcomingExamCard(exams: state.upcomingExams),
              const SizedBox(height: 22),
              _SectionTitle(title: l10n.revisionQueue),
              const SizedBox(height: 8),
              RevisionCard(items: state.pendingRevisions),
              if (state.todayAssignments.isEmpty &&
                  state.upcomingExams.isEmpty &&
                  state.pendingRevisions.isEmpty &&
                  state.todaysRoutines.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: _FreshInstallEmptyState(
                    onAddSubject: () =>
                        context.push(AppRoutes.subjectAdd),
                    onAddTask: () =>
                        context.push(AppRoutes.assignmentAdd),
                    onStartStudy: () =>
                        context.push(AppRoutes.studyTimer),
                  ),
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a small list of "what just happened" entries pulled from
  /// today's study sessions, today's due tasks, and pending revisions.
  List<RecentActivity> _buildRecentActivity({
    required HomeState state,
    required bool isBangla,
    required dynamic l10n,
  }) {
    final items = <RecentActivity>[];
    // Study sessions from today
    for (final s in state.subjectSeconds.entries) {
      if (s.value <= 0) continue;
      final subject = state.recommendation?.subject;
      if (subject == null) continue;
      if (subject.id != s.key) continue;
      items.add(RecentActivity(
        icon: Icons.timer_outlined,
        title:
            '${isBangla ? 'পড়াশোনা' : 'Studied'} ${subject.name}',
        subtitle:
            '${(s.value / 60).round()} ${isBangla ? 'মিনিট' : 'min'}',
        timestamp: DateTime.now(),
      ));
      break;
    }
    // Today's assignments
    if (state.todayAssignments.isNotEmpty) {
      final first = state.todayAssignments.first;
      items.add(RecentActivity(
        icon: Icons.task_alt_rounded,
        title: first.title,
        subtitle:
            isBangla ? 'আজকের কাজ' : 'Due today',
        timestamp: first.dueDate ?? DateTime.now(),
      ));
    }
    // Upcoming exam
    if (state.upcomingExams.isNotEmpty) {
      final ex = state.upcomingExams.first;
      items.add(RecentActivity(
        icon: Icons.event_rounded,
        title: ex.title,
        subtitle: isBangla
            ? '${daysUntilDate(ex.examDate)} দিন বাকি'
            : 'in ${daysUntilDate(ex.examDate)} days',
        timestamp: ex.examDate,
      ));
    }
    return items;
  }
}

int daysUntilDate(DateTime date) {
  final today = DateTime.now();
  final d0 = DateTime(today.year, today.month, today.day);
  final d1 = DateTime(date.year, date.month, date.day);
  return d1.difference(d0).inDays;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(title, style: AppTextStyles.titleLarge),
    );
  }
}

class _FreshInstallEmptyState extends StatelessWidget {
  const _FreshInstallEmptyState({
    required this.onAddSubject,
    required this.onAddTask,
    required this.onStartStudy,
  });
  final VoidCallback onAddSubject;
  final VoidCallback onAddTask;
  final VoidCallback onStartStudy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isBangla = l10n.isBangla;
    return Column(
      children: [
        AppEmptyState(
          title: l10n.studyNow,
          message: isBangla
              ? 'FAB (+) থেকে যেকোনো জিনিস যোগ করুন, অথবা নিচের যেকোনো বোতামে চাপ দিন।'
              : 'Tap the + button to add anything, or pick a starter below.',
          icon: Icons.auto_awesome,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            FilledButton.tonalIcon(
              icon: const Icon(Icons.menu_book_rounded),
              label: Text(l10n.addSubject),
              onPressed: onAddSubject,
            ),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.task_alt_rounded),
              label: Text(l10n.addAssignment),
              onPressed: onAddTask,
            ),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.timer_outlined),
              label: Text(l10n.startStudyCta),
              onPressed: onStartStudy,
            ),
          ],
        ),
      ],
    );
  }
}