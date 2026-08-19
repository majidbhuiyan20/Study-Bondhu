import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'services/backup_service.dart';
import 'services/local_storage_service.dart';
import '../features/subjects/repositories/subjects_repository.dart';
import '../features/assignments/repositories/assignments_repository.dart';
import '../features/exams/repositories/exams_repository.dart';
import '../features/attendance/repositories/attendance_repository.dart';
import '../features/study/repositories/study_repository.dart';
import '../features/revision/repositories/revision_repository.dart';
import '../features/notes/repositories/notes_repository.dart';
import '../features/flashcards/repositories/flashcards_repository.dart';
import '../features/expenses/repositories/expenses_repository.dart';
import '../features/analytics/repositories/analytics_repository.dart';
import '../features/profile/repositories/profile_repository.dart';
import '../features/routines/repositories/routines_repository.dart';
import '../features/timetable/repositories/timetable_repository.dart';
import '../features/resources/repositories/resources_repository.dart';

final databaseProvider = Provider<AppDatabase>((_) => AppDatabase.instance);

final localStorageProvider =
    Provider<LocalStorageService>((_) => LocalStorageService.instance);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(databaseProvider)),
);

final subjectsRepositoryProvider = Provider<SubjectsRepository>(
    (ref) => SubjectsRepository(ref.watch(databaseProvider)));

final assignmentsRepositoryProvider = Provider<AssignmentsRepository>(
    (ref) => AssignmentsRepository(ref.watch(databaseProvider)));

final examsRepositoryProvider = Provider<ExamsRepository>(
    (ref) => ExamsRepository(ref.watch(databaseProvider)));

final attendanceRepositoryProvider = Provider<AttendanceRepository>(
    (ref) => AttendanceRepository(ref.watch(databaseProvider)));

final studyRepositoryProvider = Provider<StudyRepository>(
    (ref) => StudyRepository(ref.watch(databaseProvider)));

final revisionRepositoryProvider = Provider<RevisionRepository>(
    (ref) => RevisionRepository(ref.watch(databaseProvider)));

final notesRepositoryProvider = Provider<NotesRepository>(
    (ref) => NotesRepository(ref.watch(databaseProvider)));

final flashcardsRepositoryProvider = Provider<FlashcardsRepository>(
    (ref) => FlashcardsRepository(ref.watch(databaseProvider)));

final expensesRepositoryProvider = Provider<ExpensesRepository>(
    (ref) => ExpensesRepository(ref.watch(databaseProvider)));

final analyticsRepositoryProvider = Provider<AnalyticsRepository>(
    (ref) => AnalyticsRepository(ref.watch(databaseProvider)));

final profileRepositoryProvider = Provider<ProfileRepository>(
    (ref) => ProfileRepository(ref.watch(databaseProvider)));

final routinesRepositoryProvider = Provider<RoutinesRepository>(
    (ref) => RoutinesRepository(ref.watch(databaseProvider)));

final timetableRepositoryProvider = Provider<TimetableRepository>(
    (ref) => TimetableRepository(ref.watch(databaseProvider)));

final resourcesRepositoryGlobalProvider = Provider<ResourcesRepository>(
    (ref) => ResourcesRepository(ref.watch(databaseProvider)));
