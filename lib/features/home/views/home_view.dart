import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/quick_add_sheet.dart';
import '../../settings/view_models/settings_view_model.dart';
import '../view_models/home_view_model.dart';
import '../widgets/greeting_header.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: l10n.drawerMenu,
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
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
                name: settings.locale.languageCode == 'bn'
                    ? 'বন্ধু'
                    : 'Bondhu',
              ),
              const SizedBox(height: 18),
              TodayProgressCard(state: state),
              const SizedBox(height: 18),
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
                  child: AppEmptyState(
                    title: l10n.studyNow,
                    message: l10n.emptyStateCta,
                    icon: Icons.auto_awesome,
                  ),
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
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
