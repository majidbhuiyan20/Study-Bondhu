class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Bottom nav shell
  static const String shell = '/shell';
  static const String home = '/home';
  static const String subjects = '/subjects';
  static const String study = '/study';
  static const String analytics = '/analytics';
  static const String settings = '/settings';

  // Subjects
  static const String subjectDetail = '/subjects/:id';
  static const String subjectAdd = '/subjects/add';
  static const String topicAdd = '/topics/add';
  static const String semesters = '/semesters';
  static const String semesterTimeline = '/semesters/timeline';

  // Assignments
  static const String assignments = '/assignments';
  static const String assignmentAdd = '/assignments/add';

  // Exams
  static const String exams = '/exams';
  static const String examAdd = '/exams/add';
  static const String examPreparation = '/exams/:id/preparation';

  // Attendance
  static const String attendance = '/attendance';

  // Syllabus
  static const String syllabus = '/syllabus';

  // Study
  static const String studyTimer = '/study/timer';
  static const String studyLog = '/study/log';
  static const String studySessionDetail = '/study/sessions/:id';

  // Revision
  static const String revision = '/revision';

  // Notes
  static const String notes = '/notes';
  static const String noteEditor = '/notes/editor';
  static const String noteDetail = '/notes/:id';

  // Flashcards
  static const String flashcards = '/flashcards';
  static const String flashcardDeck = '/flashcards/:id';
  static const String flashcardStudy = '/flashcards/:id/study';

  // Expenses
  static const String expenses = '/expenses';

  // Settings
  static const String settingsLanguage = '/settings/language';
  static const String settingsTheme = '/settings/theme';
  static const String settingsNotifications = '/settings/notifications';
  static const String settingsBackup = '/settings/backup';
  static const String settingsAbout = '/settings/about';

  // Backup (spec #31)
  static const String backup = '/backup';

  // Search
  static const String search = '/search';

  // Profile (class/grade)
  static const String profiles = '/profiles';

  // Routines (recurring assignments)
  static const String routines = '/routines';

  // Timetable (spec #26)
  static const String timetable = '/timetable';

  // Streak (spec #23)
  static const String streak = '/streak';

  // Local resources (spec #27)
  static const String resources = '/resources';

  // Flashcards (spec #19)
  static const String flashcardDeckAdd = '/flashcards/add';

  // Expenses (spec #20) — single screen for expense + income
  static const String expenseAdd = '/expenses/add';
  static const String incomeAdd = '/income/add';
}
