class AppConstants {
  AppConstants._();

  static const String appName = 'StudyBondhu';
  static const String appTagline = 'Your academic companion';

  // Database
  static const String dbName = 'study_bondhu.db';
  static const int dbVersion = 6;

  // Keys
  static const String prefLocale = 'pref_locale';
  static const String prefThemeMode = 'pref_theme_mode';
  static const String prefOnboardingDone = 'pref_onboarding_done';
  static const String prefDailyGoalMinutes = 'pref_daily_goal_minutes';
  static const String prefNotificationsEnabled = 'pref_notifications_enabled';

  // Per-category notification toggles (spec #24). All default to true so
  // existing users keep getting reminders until they opt out individually.
  static const String prefNotifAssignments = 'pref_notif_assignments';
  static const String prefNotifRevisions = 'pref_notif_revisions';
  static const String prefNotifExams = 'pref_notif_exams';
  static const String prefNotifDailyGoal = 'pref_notif_daily_goal';
  static const String prefNotifAttendance = 'pref_notif_attendance';

  // Defaults
  static const int defaultDailyGoalMinutes = 180;

  // Supported locales
  static const String localeEn = 'en';
  static const String localeBn = 'bn';
}
