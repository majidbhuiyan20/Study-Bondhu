import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/analytics/views/analytics_view.dart';
import '../features/assignments/views/assignment_add_view.dart';
import '../features/assignments/views/assignments_view.dart';
import '../features/attendance/views/attendance_view.dart';
import '../features/exams/views/exam_add_view.dart';
import '../features/exams/views/exam_preparation_view.dart';
import '../features/exams/views/exams_view.dart';
import '../features/expenses/views/expense_add_view.dart';
import '../features/expenses/views/expenses_view.dart';
import '../features/expenses/views/income_add_view.dart';
import '../features/home/views/main_shell.dart';
import '../features/notes/views/notes_view.dart';
import '../features/profile/views/onboarding_view.dart';
import '../features/profile/views/profile_view.dart';
import '../features/profile/views/profiles_view.dart';
import '../features/profile/views/streak_view.dart';
import '../features/profile/views/backup_view.dart';
import '../features/revision/views/revision_view.dart';
import '../features/routines/views/routines_view.dart';
import '../features/timetable/views/timetable_view.dart';
import '../features/resources/views/resources_view.dart';
import '../features/search/views/search_view.dart';
import '../features/settings/views/settings_view.dart';
import '../features/study/views/study_log_view.dart';
import '../features/study/views/study_view.dart';
import '../features/subjects/views/semesters_view.dart';
import '../features/subjects/views/semester_timeline_view.dart';
import '../features/subjects/views/subject_add_view.dart';
import '../features/subjects/views/subject_detail_view.dart';
import '../features/subjects/views/subjects_view.dart';
import '../features/subjects/views/topic_add_view.dart';
import '../core/services/local_storage_service.dart';
import 'constants/app_routes.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.shell,
    redirect: (context, state) {
      // First launch: show onboarding.
      final onboardingDone = LocalStorageService.instance.onboardingDone;
      final isOnboarding = state.uri.toString() == AppRoutes.onboarding;
      if (!onboardingDone && !isOnboarding) {
        return AppRoutes.onboarding;
      }
      if (onboardingDone && isOnboarding) {
        return AppRoutes.shell;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: AppRoutes.shell,
        builder: (context, state) => const MainShell(),
      ),
      // Direct route to the subjects list. Used after onboarding so the
      // user lands on the same screen they'll see in the "Subjects" tab.
      GoRoute(
        path: AppRoutes.subjects,
        builder: (context, state) => const SubjectsView(),
      ),
      // Direct views for tab destinations (used by recommendation cards
      // and "see all" links that want to open the tab as its own page).
      GoRoute(
        path: AppRoutes.study,
        builder: (context, state) => const StudyView(),
      ),
      GoRoute(
        path: AppRoutes.analytics,
        builder: (context, state) => const AnalyticsView(),
      ),
      GoRoute(
        path: AppRoutes.assignments,
        builder: (context, state) => const AssignmentsView(),
      ),
      GoRoute(
        path: AppRoutes.assignmentAdd,
        builder: (context, state) => const AssignmentAddView(),
      ),
      GoRoute(
        path: AppRoutes.exams,
        builder: (context, state) => const ExamsView(),
      ),
      GoRoute(
        path: AppRoutes.examAdd,
        builder: (context, state) => const ExamAddView(),
      ),
      GoRoute(
        path: AppRoutes.examPreparation,
        builder: (context, state) {
          final id =
              int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ExamPreparationView(examId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.attendance,
        builder: (context, state) => const AttendanceView(),
      ),
      GoRoute(
        path: AppRoutes.subjectAdd,
        builder: (context, state) => const SubjectAddView(),
      ),
      GoRoute(
        path: AppRoutes.topicAdd,
        builder: (context, state) {
          final id = int.tryParse(
              state.uri.queryParameters['subjectId'] ?? '');
          return TopicAddView(initialSubjectId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.semesters,
        builder: (context, state) => const SemestersView(),
      ),
      GoRoute(
        path: AppRoutes.semesterTimeline,
        builder: (context, state) => const SemesterTimelineView(),
      ),
      GoRoute(
        path: AppRoutes.subjectDetail,
        builder: (context, state) {
          final id =
              int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return SubjectDetailView(subjectId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.studyLog,
        builder: (context, state) => const StudyLogView(),
      ),
      GoRoute(
        path: AppRoutes.revision,
        builder: (context, state) => const RevisionView(),
      ),
      GoRoute(
        path: AppRoutes.notes,
        builder: (context, state) => const NotesView(),
      ),
      GoRoute(
        path: AppRoutes.expenses,
        builder: (context, state) => const ExpensesView(),
      ),
      GoRoute(
        path: AppRoutes.expenseAdd,
        builder: (context, state) => const ExpenseAddView(),
      ),
      GoRoute(
        path: AppRoutes.incomeAdd,
        builder: (context, state) => const IncomeAddView(),
      ),
      GoRoute(
        path: AppRoutes.profiles,
        builder: (context, state) => const ProfilesView(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileView(),
      ),
      GoRoute(
        path: AppRoutes.routines,
        builder: (context, state) => const RoutinesView(),
      ),
      GoRoute(
        path: AppRoutes.timetable,
        builder: (context, state) => const TimetableView(),
      ),
      GoRoute(
        path: AppRoutes.streak,
        builder: (context, state) => const StreakView(),
      ),
      GoRoute(
        path: AppRoutes.backup,
        builder: (context, state) => const BackupView(),
      ),
      GoRoute(
        path: AppRoutes.resources,
        builder: (context, state) => const ResourcesView(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchView(),
      ),
      // Direct top-level views for tab destinations that are also
      // surfaced from the drawer (so users can deep-link or push).
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsView(),
      ),
      GoRoute(
        path: AppRoutes.settingsLanguage,
        builder: (context, state) => const SettingsView(),
      ),
      GoRoute(
        path: AppRoutes.settingsTheme,
        builder: (context, state) => const SettingsView(),
      ),
      GoRoute(
        path: AppRoutes.settingsNotifications,
        builder: (context, state) => const SettingsView(),
      ),
      GoRoute(
        path: AppRoutes.settingsBackup,
        builder: (context, state) => const SettingsView(),
      ),
      GoRoute(
        path: AppRoutes.settingsAbout,
        builder: (context, state) => const SettingsView(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
}