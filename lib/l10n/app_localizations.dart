import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @active_chip.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active_chip;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @add_assignment.
  ///
  /// In en, this message translates to:
  /// **'Add Assignment'**
  String get add_assignment;

  /// No description provided for @add_exam.
  ///
  /// In en, this message translates to:
  /// **'Add Exam'**
  String get add_exam;

  /// No description provided for @add_goal.
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get add_goal;

  /// No description provided for @add_new_note.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get add_new_note;

  /// No description provided for @add_profile.
  ///
  /// In en, this message translates to:
  /// **'Add profile'**
  String get add_profile;

  /// No description provided for @add_semester.
  ///
  /// In en, this message translates to:
  /// **'Add semester'**
  String get add_semester;

  /// No description provided for @add_subject.
  ///
  /// In en, this message translates to:
  /// **'Add Subject'**
  String get add_subject;

  /// No description provided for @add_subject_title.
  ///
  /// In en, this message translates to:
  /// **'Add subject'**
  String get add_subject_title;

  /// No description provided for @add_subtask.
  ///
  /// In en, this message translates to:
  /// **'Add subtask'**
  String get add_subtask;

  /// No description provided for @add_syllabus_item.
  ///
  /// In en, this message translates to:
  /// **'Add syllabus item'**
  String get add_syllabus_item;

  /// No description provided for @add_topic.
  ///
  /// In en, this message translates to:
  /// **'Add topic'**
  String get add_topic;

  /// No description provided for @add_topic_btn.
  ///
  /// In en, this message translates to:
  /// **'Add topic'**
  String get add_topic_btn;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'StudyBondhu'**
  String get app_name;

  /// No description provided for @assignment_add_title.
  ///
  /// In en, this message translates to:
  /// **'Add assignment'**
  String get assignment_add_title;

  /// No description provided for @assignment_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit assignment'**
  String get assignment_edit_title;

  /// No description provided for @assignment_estimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated minutes'**
  String get assignment_estimated;

  /// No description provided for @assignment_notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get assignment_notes;

  /// No description provided for @assignment_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get assignment_type;

  /// No description provided for @assignments.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get assignments;

  /// No description provided for @assignments_hint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first assignment'**
  String get assignments_hint;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @attended_label.
  ///
  /// In en, this message translates to:
  /// **'attended'**
  String get attended_label;

  /// No description provided for @avg_focus.
  ///
  /// In en, this message translates to:
  /// **'Avg focus'**
  String get avg_focus;

  /// No description provided for @avg_session.
  ///
  /// In en, this message translates to:
  /// **'Avg session'**
  String get avg_session;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @background_resume.
  ///
  /// In en, this message translates to:
  /// **'Resume or finish?'**
  String get background_resume;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backup;

  /// No description provided for @bangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get bangla;

  /// No description provided for @bulk_add.
  ///
  /// In en, this message translates to:
  /// **'Bulk add'**
  String get bulk_add;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cannot_be_undone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get cannot_be_undone;

  /// No description provided for @cannot_undo.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get cannot_undo;

  /// No description provided for @card_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get card_back;

  /// No description provided for @card_front.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get card_front;

  /// No description provided for @cat_academic_fee.
  ///
  /// In en, this message translates to:
  /// **'Academic fee'**
  String get cat_academic_fee;

  /// No description provided for @cat_books.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get cat_books;

  /// No description provided for @cat_food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get cat_food;

  /// No description provided for @cat_mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get cat_mobile;

  /// No description provided for @cat_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get cat_other;

  /// No description provided for @cat_printing.
  ///
  /// In en, this message translates to:
  /// **'Printing'**
  String get cat_printing;

  /// No description provided for @cat_transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get cat_transport;

  /// No description provided for @change_semester.
  ///
  /// In en, this message translates to:
  /// **'Change semester'**
  String get change_semester;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @color_label.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color_label;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @completed_section.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed_section;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @confirm_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete?'**
  String get confirm_delete;

  /// No description provided for @course_code_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. CSE-201'**
  String get course_code_hint;

  /// No description provided for @course_code_opt.
  ///
  /// In en, this message translates to:
  /// **'Course code (optional)'**
  String get course_code_opt;

  /// No description provided for @credit_bangla.
  ///
  /// In en, this message translates to:
  /// **'৩ ক্রেডিট'**
  String get credit_bangla;

  /// No description provided for @credit_opt.
  ///
  /// In en, this message translates to:
  /// **'Credit (optional)'**
  String get credit_opt;

  /// No description provided for @credit_short.
  ///
  /// In en, this message translates to:
  /// **'cr'**
  String get credit_short;

  /// No description provided for @credits_short.
  ///
  /// In en, this message translates to:
  /// **'credits'**
  String get credits_short;

  /// No description provided for @daily_goal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get daily_goal;

  /// No description provided for @dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get dark_mode;

  /// No description provided for @deck_name.
  ///
  /// In en, this message translates to:
  /// **'Deck name'**
  String get deck_name;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @delete_semester.
  ///
  /// In en, this message translates to:
  /// **'Delete semester'**
  String get delete_semester;

  /// No description provided for @delete_semester_message.
  ///
  /// In en, this message translates to:
  /// **'All subjects under this semester will be removed.'**
  String get delete_semester_message;

  /// No description provided for @delete_semester_title.
  ///
  /// In en, this message translates to:
  /// **'Delete this semester?'**
  String get delete_semester_title;

  /// No description provided for @delete_subject.
  ///
  /// In en, this message translates to:
  /// **'Delete subject'**
  String get delete_subject;

  /// No description provided for @delete_subject_body.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove all related items. This action cannot be undone.'**
  String get delete_subject_body;

  /// No description provided for @delete_subject_title.
  ///
  /// In en, this message translates to:
  /// **'Delete \"%s\"?'**
  String get delete_subject_title;

  /// No description provided for @delete_subject_warning.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove'**
  String get delete_subject_warning;

  /// No description provided for @delete_topic.
  ///
  /// In en, this message translates to:
  /// **'Delete topic'**
  String get delete_topic;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @discard_session.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard_session;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @drawer_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get drawer_about;

  /// No description provided for @drawer_analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get drawer_analytics;

  /// No description provided for @drawer_assignments.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get drawer_assignments;

  /// No description provided for @drawer_attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get drawer_attendance;

  /// No description provided for @drawer_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get drawer_dashboard;

  /// No description provided for @drawer_exams.
  ///
  /// In en, this message translates to:
  /// **'Exams'**
  String get drawer_exams;

  /// No description provided for @drawer_expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get drawer_expenses;

  /// No description provided for @drawer_flashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get drawer_flashcards;

  /// No description provided for @drawer_goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get drawer_goals;

  /// No description provided for @drawer_logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get drawer_logout;

  /// No description provided for @drawer_menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get drawer_menu;

  /// No description provided for @drawer_notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get drawer_notes;

  /// No description provided for @drawer_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get drawer_profile;

  /// No description provided for @drawer_revision.
  ///
  /// In en, this message translates to:
  /// **'Revision'**
  String get drawer_revision;

  /// No description provided for @drawer_routines.
  ///
  /// In en, this message translates to:
  /// **'Class Routine'**
  String get drawer_routines;

  /// No description provided for @drawer_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get drawer_search;

  /// No description provided for @drawer_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawer_settings;

  /// No description provided for @drawer_subjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get drawer_subjects;

  /// No description provided for @drawer_timeline.
  ///
  /// In en, this message translates to:
  /// **'Semester Timeline'**
  String get drawer_timeline;

  /// No description provided for @due_date.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get due_date;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @edit_note.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get edit_note;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get edit_profile;

  /// No description provided for @edit_semester.
  ///
  /// In en, this message translates to:
  /// **'Edit semester'**
  String get edit_semester;

  /// No description provided for @edit_subject.
  ///
  /// In en, this message translates to:
  /// **'Edit subject'**
  String get edit_subject;

  /// No description provided for @edit_topic.
  ///
  /// In en, this message translates to:
  /// **'Edit topic'**
  String get edit_topic;

  /// No description provided for @empty_state_cta.
  ///
  /// In en, this message translates to:
  /// **'Add a subject, assignment, exam or routine to get personalised recommendations'**
  String get empty_state_cta;

  /// No description provided for @empty_subjects_hint.
  ///
  /// In en, this message translates to:
  /// **'Add your first subject to start tracking'**
  String get empty_subjects_hint;

  /// No description provided for @end_date.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get end_date;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @exam_add_title.
  ///
  /// In en, this message translates to:
  /// **'Add exam'**
  String get exam_add_title;

  /// No description provided for @exam_date.
  ///
  /// In en, this message translates to:
  /// **'Exam date'**
  String get exam_date;

  /// No description provided for @exam_days_left.
  ///
  /// In en, this message translates to:
  /// **'days left'**
  String get exam_days_left;

  /// No description provided for @exam_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get exam_location;

  /// No description provided for @exam_prep_cta.
  ///
  /// In en, this message translates to:
  /// **'View preparation'**
  String get exam_prep_cta;

  /// No description provided for @exam_prep_title.
  ///
  /// In en, this message translates to:
  /// **'Exam preparation'**
  String get exam_prep_title;

  /// No description provided for @exam_time.
  ///
  /// In en, this message translates to:
  /// **'Time (e.g. 09:00 – 11:00)'**
  String get exam_time;

  /// No description provided for @exam_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get exam_today;

  /// No description provided for @exam_tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get exam_tomorrow;

  /// No description provided for @exams.
  ///
  /// In en, this message translates to:
  /// **'Exams'**
  String get exams;

  /// No description provided for @exams_hint.
  ///
  /// In en, this message translates to:
  /// **'Add upcoming exams to stay prepared'**
  String get exams_hint;

  /// No description provided for @expense_amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expense_amount;

  /// No description provided for @expense_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expense_category;

  /// No description provided for @expense_note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get expense_note;

  /// No description provided for @expense_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get expense_title;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @expenses_hint.
  ///
  /// In en, this message translates to:
  /// **'Track study expenses'**
  String get expenses_hint;

  /// No description provided for @export_data.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get export_data;

  /// No description provided for @flashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get flashcards;

  /// No description provided for @flashcards_hint.
  ///
  /// In en, this message translates to:
  /// **'Build decks for revision'**
  String get flashcards_hint;

  /// No description provided for @flashcards_label.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get flashcards_label;

  /// No description provided for @focus_mode.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focus_mode;

  /// No description provided for @focus_mode_title.
  ///
  /// In en, this message translates to:
  /// **'Focus mode'**
  String get focus_mode_title;

  /// No description provided for @free_mode.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free_mode;

  /// No description provided for @free_mode_title.
  ///
  /// In en, this message translates to:
  /// **'Free mode'**
  String get free_mode_title;

  /// No description provided for @goal_daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get goal_daily;

  /// No description provided for @goal_progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get goal_progress;

  /// No description provided for @goal_reached_today.
  ///
  /// In en, this message translates to:
  /// **'Goal reached today — amazing!'**
  String get goal_reached_today;

  /// No description provided for @goal_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get goal_total;

  /// No description provided for @goal_weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get goal_weekly;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @good_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get good_afternoon;

  /// No description provided for @good_evening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get good_evening;

  /// No description provided for @good_morning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get good_morning;

  /// No description provided for @good_night.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get good_night;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @how_did_it_go.
  ///
  /// In en, this message translates to:
  /// **'How did it go?'**
  String get how_did_it_go;

  /// No description provided for @import_data.
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get import_data;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @last_7_days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last_7_days;

  /// No description provided for @late.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get late;

  /// No description provided for @late_night.
  ///
  /// In en, this message translates to:
  /// **'Up late'**
  String get late_night;

  /// No description provided for @least_studied.
  ///
  /// In en, this message translates to:
  /// **'Least studied'**
  String get least_studied;

  /// No description provided for @light_mode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get light_mode;

  /// No description provided for @make_active.
  ///
  /// In en, this message translates to:
  /// **'Make active'**
  String get make_active;

  /// No description provided for @mark_absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get mark_absent;

  /// No description provided for @mark_late.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get mark_late;

  /// No description provided for @mark_present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get mark_present;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @minutes_short.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutes_short;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @most_studied.
  ///
  /// In en, this message translates to:
  /// **'Most studied'**
  String get most_studied;

  /// No description provided for @most_studied_topic.
  ///
  /// In en, this message translates to:
  /// **'Most studied topic'**
  String get most_studied_topic;

  /// No description provided for @nav_analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get nav_analytics;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nav_settings;

  /// No description provided for @nav_study.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get nav_study;

  /// No description provided for @nav_subjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get nav_subjects;

  /// No description provided for @new_deck.
  ///
  /// In en, this message translates to:
  /// **'New deck'**
  String get new_deck;

  /// No description provided for @new_expense.
  ///
  /// In en, this message translates to:
  /// **'New expense'**
  String get new_expense;

  /// No description provided for @new_note.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get new_note;

  /// No description provided for @new_semester.
  ///
  /// In en, this message translates to:
  /// **'New semester'**
  String get new_semester;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @no_assignments.
  ///
  /// In en, this message translates to:
  /// **'No assignments yet'**
  String get no_assignments;

  /// No description provided for @no_dates_set.
  ///
  /// In en, this message translates to:
  /// **'No dates set'**
  String get no_dates_set;

  /// No description provided for @no_exams.
  ///
  /// In en, this message translates to:
  /// **'No exams yet'**
  String get no_exams;

  /// No description provided for @no_expenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get no_expenses;

  /// No description provided for @no_flashcards.
  ///
  /// In en, this message translates to:
  /// **'No flashcards yet'**
  String get no_flashcards;

  /// No description provided for @no_notes.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get no_notes;

  /// No description provided for @no_notes_hint.
  ///
  /// In en, this message translates to:
  /// **'Capture your study notes here'**
  String get no_notes_hint;

  /// No description provided for @no_revision.
  ///
  /// In en, this message translates to:
  /// **'No revisions scheduled'**
  String get no_revision;

  /// No description provided for @no_revision_items.
  ///
  /// In en, this message translates to:
  /// **'No revisions scheduled'**
  String get no_revision_items;

  /// No description provided for @no_semesters_hint.
  ///
  /// In en, this message translates to:
  /// **'Add a semester (e.g. \"Fall 2025\") to group your subjects'**
  String get no_semesters_hint;

  /// No description provided for @no_sessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions'**
  String get no_sessions;

  /// No description provided for @no_sessions_hint.
  ///
  /// In en, this message translates to:
  /// **'Use the timer to log study sessions'**
  String get no_sessions_hint;

  /// No description provided for @no_subjects.
  ///
  /// In en, this message translates to:
  /// **'No subjects yet'**
  String get no_subjects;

  /// No description provided for @no_subtasks.
  ///
  /// In en, this message translates to:
  /// **'No subtasks yet'**
  String get no_subtasks;

  /// No description provided for @no_syllabus.
  ///
  /// In en, this message translates to:
  /// **'No syllabus yet'**
  String get no_syllabus;

  /// No description provided for @no_syllabus_hint.
  ///
  /// In en, this message translates to:
  /// **'Add your syllabus to track progress'**
  String get no_syllabus_hint;

  /// No description provided for @no_topics.
  ///
  /// In en, this message translates to:
  /// **'No topics yet'**
  String get no_topics;

  /// No description provided for @no_topics_hint.
  ///
  /// In en, this message translates to:
  /// **'Break your subject into trackable topics'**
  String get no_topics_hint;

  /// No description provided for @no_weak_topics.
  ///
  /// In en, this message translates to:
  /// **'No weak topics — great!'**
  String get no_weak_topics;

  /// No description provided for @note_body.
  ///
  /// In en, this message translates to:
  /// **'Write your note…'**
  String get note_body;

  /// No description provided for @note_search.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get note_search;

  /// No description provided for @note_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get note_title;

  /// No description provided for @note_title_hint.
  ///
  /// In en, this message translates to:
  /// **'Note title'**
  String get note_title_hint;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notes_field.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes_field;

  /// No description provided for @notes_hint.
  ///
  /// In en, this message translates to:
  /// **'Capture your study notes'**
  String get notes_hint;

  /// No description provided for @notes_label.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes_label;

  /// No description provided for @notif_assign.
  ///
  /// In en, this message translates to:
  /// **'Assignment reminders'**
  String get notif_assign;

  /// No description provided for @notif_att.
  ///
  /// In en, this message translates to:
  /// **'Attendance alerts'**
  String get notif_att;

  /// No description provided for @notif_daily.
  ///
  /// In en, this message translates to:
  /// **'Daily goal reminder'**
  String get notif_daily;

  /// No description provided for @notif_exam.
  ///
  /// In en, this message translates to:
  /// **'Exam reminders'**
  String get notif_exam;

  /// No description provided for @notif_rev.
  ///
  /// In en, this message translates to:
  /// **'Revision reminders'**
  String get notif_rev;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline-first'**
  String get offline;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @onboarding_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboarding_continue;

  /// No description provided for @onboarding_get_started.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboarding_get_started;

  /// No description provided for @onboarding_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get onboarding_skip;

  /// No description provided for @onboarding_step_done.
  ///
  /// In en, this message translates to:
  /// **'You\\\'re all set!'**
  String get onboarding_step_done;

  /// No description provided for @onboarding_step_goal.
  ///
  /// In en, this message translates to:
  /// **'Set your daily goal'**
  String get onboarding_step_goal;

  /// No description provided for @onboarding_step_profile.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get onboarding_step_profile;

  /// No description provided for @onboarding_step_semester.
  ///
  /// In en, this message translates to:
  /// **'Add a semester'**
  String get onboarding_step_semester;

  /// No description provided for @onboarding_step_subjects.
  ///
  /// In en, this message translates to:
  /// **'Add subjects'**
  String get onboarding_step_subjects;

  /// No description provided for @onboarding_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to StudyBondhu'**
  String get onboarding_welcome;

  /// No description provided for @onboarding_welcome_body.
  ///
  /// In en, this message translates to:
  /// **'Your offline study companion — built for Bangladeshi students.'**
  String get onboarding_welcome_body;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @pending_section.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending_section;

  /// No description provided for @percent_of_daily_goal.
  ///
  /// In en, this message translates to:
  /// **'% of daily goal'**
  String get percent_of_daily_goal;

  /// No description provided for @pin_note.
  ///
  /// In en, this message translates to:
  /// **'Pin note'**
  String get pin_note;

  /// No description provided for @pomodoro.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro'**
  String get pomodoro;

  /// No description provided for @pomodoro_mode_title.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro'**
  String get pomodoro_mode_title;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @priority_high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priority_high;

  /// No description provided for @priority_low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priority_low;

  /// No description provided for @priority_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priority_medium;

  /// No description provided for @profile_chip.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_chip;

  /// No description provided for @profiles.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get profiles;

  /// No description provided for @qa_attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get qa_attendance;

  /// No description provided for @qa_exam.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get qa_exam;

  /// No description provided for @qa_expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get qa_expense;

  /// No description provided for @qa_flashcard.
  ///
  /// In en, this message translates to:
  /// **'Flashcard'**
  String get qa_flashcard;

  /// No description provided for @qa_note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get qa_note;

  /// No description provided for @qa_study.
  ///
  /// In en, this message translates to:
  /// **'Study session'**
  String get qa_study;

  /// No description provided for @qa_subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get qa_subject;

  /// No description provided for @qa_task.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get qa_task;

  /// No description provided for @qa_topic.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get qa_topic;

  /// No description provided for @quick_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get quick_add;

  /// No description provided for @quick_mark.
  ///
  /// In en, this message translates to:
  /// **'Quick mark'**
  String get quick_mark;

  /// No description provided for @rate_again.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get rate_again;

  /// No description provided for @rate_easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get rate_easy;

  /// No description provided for @rate_good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get rate_good;

  /// No description provided for @rate_okay.
  ///
  /// In en, this message translates to:
  /// **'Okay 🙂'**
  String get rate_okay;

  /// No description provided for @rate_strong.
  ///
  /// In en, this message translates to:
  /// **'Strong 😎'**
  String get rate_strong;

  /// No description provided for @rate_weak.
  ///
  /// In en, this message translates to:
  /// **'Weak 😕'**
  String get rate_weak;

  /// No description provided for @readiness_overall.
  ///
  /// In en, this message translates to:
  /// **'Overall readiness'**
  String get readiness_overall;

  /// No description provided for @readiness_practice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get readiness_practice;

  /// No description provided for @readiness_revision.
  ///
  /// In en, this message translates to:
  /// **'Revision'**
  String get readiness_revision;

  /// No description provided for @readiness_study.
  ///
  /// In en, this message translates to:
  /// **'Study time'**
  String get readiness_study;

  /// No description provided for @readiness_syllabus.
  ///
  /// In en, this message translates to:
  /// **'Syllabus'**
  String get readiness_syllabus;

  /// No description provided for @reason_exam_soon.
  ///
  /// In en, this message translates to:
  /// **'Exam coming up — prepare'**
  String get reason_exam_soon;

  /// No description provided for @reason_lowest_study.
  ///
  /// In en, this message translates to:
  /// **'Lowest study time this week — focus here'**
  String get reason_lowest_study;

  /// No description provided for @reason_weak_topic.
  ///
  /// In en, this message translates to:
  /// **'Weak topic — needs practice'**
  String get reason_weak_topic;

  /// No description provided for @recommended_today.
  ///
  /// In en, this message translates to:
  /// **'Recommended for today'**
  String get recommended_today;

  /// No description provided for @rename_topic.
  ///
  /// In en, this message translates to:
  /// **'Rename topic'**
  String get rename_topic;

  /// No description provided for @required_field.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required_field;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @revision_add_title.
  ///
  /// In en, this message translates to:
  /// **'Schedule revision'**
  String get revision_add_title;

  /// No description provided for @revision_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get revision_general;

  /// No description provided for @revision_mark_done.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get revision_mark_done;

  /// No description provided for @revision_next.
  ///
  /// In en, this message translates to:
  /// **'Next: '**
  String get revision_next;

  /// No description provided for @revision_queue.
  ///
  /// In en, this message translates to:
  /// **'Revision Queue'**
  String get revision_queue;

  /// No description provided for @revision_schedule.
  ///
  /// In en, this message translates to:
  /// **'Revision schedule'**
  String get revision_schedule;

  /// No description provided for @revision_subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get revision_subject;

  /// No description provided for @revision_topic.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get revision_topic;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @save_session.
  ///
  /// In en, this message translates to:
  /// **'Save session'**
  String get save_session;

  /// No description provided for @save_subject.
  ///
  /// In en, this message translates to:
  /// **'Save subject'**
  String get save_subject;

  /// No description provided for @scenario_skips_left.
  ///
  /// In en, this message translates to:
  /// **'You can miss %d more'**
  String get scenario_skips_left;

  /// No description provided for @scenario_will_drop.
  ///
  /// In en, this message translates to:
  /// **'Will drop to %d%%'**
  String get scenario_will_drop;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @search_empty.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get search_empty;

  /// No description provided for @search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search subjects, tasks, exams, notes…'**
  String get search_hint;

  /// No description provided for @see_all.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get see_all;

  /// No description provided for @semester_label.
  ///
  /// In en, this message translates to:
  /// **'Semester'**
  String get semester_label;

  /// No description provided for @semester_name.
  ///
  /// In en, this message translates to:
  /// **'Semester name'**
  String get semester_name;

  /// No description provided for @semester_name_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Fall 2025 / ২০২৫ সেশন'**
  String get semester_name_hint;

  /// No description provided for @semester_timeline.
  ///
  /// In en, this message translates to:
  /// **'Semester timeline'**
  String get semester_timeline;

  /// No description provided for @semester_timeline_empty.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get semester_timeline_empty;

  /// No description provided for @semester_timeline_hint.
  ///
  /// In en, this message translates to:
  /// **'Add assignments and exams to see your semester laid out by month.'**
  String get semester_timeline_hint;

  /// No description provided for @session_complete_title.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get session_complete_title;

  /// No description provided for @session_notes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get session_notes;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @set_up_profile.
  ///
  /// In en, this message translates to:
  /// **'Set up profile'**
  String get set_up_profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @start_date.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get start_date;

  /// No description provided for @start_study.
  ///
  /// In en, this message translates to:
  /// **'Start study'**
  String get start_study;

  /// No description provided for @start_study_cta.
  ///
  /// In en, this message translates to:
  /// **'Start study session'**
  String get start_study_cta;

  /// No description provided for @start_timer.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start_timer;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @streak_days.
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get streak_days;

  /// No description provided for @student_id.
  ///
  /// In en, this message translates to:
  /// **'Student ID'**
  String get student_id;

  /// No description provided for @study_log.
  ///
  /// In en, this message translates to:
  /// **'Study log'**
  String get study_log;

  /// No description provided for @study_now.
  ///
  /// In en, this message translates to:
  /// **'What should I study now?'**
  String get study_now;

  /// No description provided for @study_recommendation.
  ///
  /// In en, this message translates to:
  /// **'Study Recommendation'**
  String get study_recommendation;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @subject_color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get subject_color;

  /// No description provided for @subject_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete subject'**
  String get subject_delete;

  /// No description provided for @subject_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit subject'**
  String get subject_edit;

  /// No description provided for @subject_name.
  ///
  /// In en, this message translates to:
  /// **'Subject name'**
  String get subject_name;

  /// No description provided for @subject_name_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Data Structures'**
  String get subject_name_hint;

  /// No description provided for @subject_not_found.
  ///
  /// In en, this message translates to:
  /// **'Subject no longer exists'**
  String get subject_not_found;

  /// No description provided for @subject_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get subject_share;

  /// No description provided for @subjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get subjects;

  /// No description provided for @subjects_hint.
  ///
  /// In en, this message translates to:
  /// **'Add subjects to start tracking'**
  String get subjects_hint;

  /// No description provided for @subtask_hint.
  ///
  /// In en, this message translates to:
  /// **'Break this down into smaller steps'**
  String get subtask_hint;

  /// No description provided for @subtasks.
  ///
  /// In en, this message translates to:
  /// **'Subtasks'**
  String get subtasks;

  /// No description provided for @syllabus.
  ///
  /// In en, this message translates to:
  /// **'Syllabus'**
  String get syllabus;

  /// No description provided for @syllabus_add.
  ///
  /// In en, this message translates to:
  /// **'Add syllabus item'**
  String get syllabus_add;

  /// No description provided for @syllabus_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get syllabus_delete;

  /// No description provided for @syllabus_label.
  ///
  /// In en, this message translates to:
  /// **'Syllabus'**
  String get syllabus_label;

  /// No description provided for @syllabus_rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get syllabus_rename;

  /// No description provided for @system_mode.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system_mode;

  /// No description provided for @tab_assignments.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get tab_assignments;

  /// No description provided for @tab_attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get tab_attendance;

  /// No description provided for @tab_day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get tab_day;

  /// No description provided for @tab_exams.
  ///
  /// In en, this message translates to:
  /// **'Exams'**
  String get tab_exams;

  /// No description provided for @tab_month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get tab_month;

  /// No description provided for @tab_notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get tab_notes;

  /// No description provided for @tab_study_time.
  ///
  /// In en, this message translates to:
  /// **'Study time'**
  String get tab_study_time;

  /// No description provided for @tab_subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get tab_subject;

  /// No description provided for @tab_syllabus.
  ///
  /// In en, this message translates to:
  /// **'Syllabus'**
  String get tab_syllabus;

  /// No description provided for @tab_topic.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get tab_topic;

  /// No description provided for @tab_topics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get tab_topics;

  /// No description provided for @tab_week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get tab_week;

  /// No description provided for @target_attendance.
  ///
  /// In en, this message translates to:
  /// **'Target attendance'**
  String get target_attendance;

  /// No description provided for @target_min.
  ///
  /// In en, this message translates to:
  /// **'Target (minutes)'**
  String get target_min;

  /// No description provided for @target_percent.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target_percent;

  /// No description provided for @teacher_opt.
  ///
  /// In en, this message translates to:
  /// **'Teacher (optional)'**
  String get teacher_opt;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @timeline_empty.
  ///
  /// In en, this message translates to:
  /// **'Add a semester to see your academic timeline'**
  String get timeline_empty;

  /// No description provided for @timeline_title.
  ///
  /// In en, this message translates to:
  /// **'Semester timeline'**
  String get timeline_title;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @todays_study.
  ///
  /// In en, this message translates to:
  /// **'Today\\\'s study'**
  String get todays_study;

  /// No description provided for @topic_picker.
  ///
  /// In en, this message translates to:
  /// **'Topic (optional)'**
  String get topic_picker;

  /// No description provided for @topic_status_label.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get topic_status_label;

  /// No description provided for @topics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get topics;

  /// No description provided for @topics_label.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get topics_label;

  /// No description provided for @total_hours.
  ///
  /// In en, this message translates to:
  /// **'Total hours'**
  String get total_hours;

  /// No description provided for @total_sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get total_sessions;

  /// No description provided for @total_study_time.
  ///
  /// In en, this message translates to:
  /// **'Total study time'**
  String get total_study_time;

  /// No description provided for @unpin_note.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpin_note;

  /// No description provided for @upcoming_exams.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Exams'**
  String get upcoming_exams;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @view_scenarios.
  ///
  /// In en, this message translates to:
  /// **'View scenarios'**
  String get view_scenarios;

  /// No description provided for @weak_topics.
  ///
  /// In en, this message translates to:
  /// **'Weak topics'**
  String get weak_topics;

  /// No description provided for @weakness_radar.
  ///
  /// In en, this message translates to:
  /// **'Weakness Radar'**
  String get weakness_radar;

  /// No description provided for @weekly_goal.
  ///
  /// In en, this message translates to:
  /// **'Weekly goal'**
  String get weekly_goal;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @add_topic_cta.
  ///
  /// In en, this message translates to:
  /// **'Add topic'**
  String get add_topic_cta;

  /// No description provided for @attendance_title.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance_title;

  /// No description provided for @close_button.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close_button;

  /// No description provided for @course_code_optional.
  ///
  /// In en, this message translates to:
  /// **'Course code (optional)'**
  String get course_code_optional;

  /// No description provided for @credit_optional.
  ///
  /// In en, this message translates to:
  /// **'Credit (optional)'**
  String get credit_optional;

  /// No description provided for @exam_preparation_cta.
  ///
  /// In en, this message translates to:
  /// **'Prepare'**
  String get exam_preparation_cta;

  /// No description provided for @exam_preparation_title.
  ///
  /// In en, this message translates to:
  /// **'Exam Preparation'**
  String get exam_preparation_title;

  /// No description provided for @no_sessions_label.
  ///
  /// In en, this message translates to:
  /// **'No sessions'**
  String get no_sessions_label;

  /// No description provided for @no_study_sessions.
  ///
  /// In en, this message translates to:
  /// **'No study sessions yet'**
  String get no_study_sessions;

  /// No description provided for @no_syllabus_yet.
  ///
  /// In en, this message translates to:
  /// **'No syllabus yet'**
  String get no_syllabus_yet;

  /// No description provided for @note_body_hint.
  ///
  /// In en, this message translates to:
  /// **'Write your notes here...'**
  String get note_body_hint;

  /// No description provided for @quick_add_attendance.
  ///
  /// In en, this message translates to:
  /// **'Mark attendance'**
  String get quick_add_attendance;

  /// No description provided for @quick_add_exam.
  ///
  /// In en, this message translates to:
  /// **'Quick add exam'**
  String get quick_add_exam;

  /// No description provided for @quick_add_expense.
  ///
  /// In en, this message translates to:
  /// **'Quick add expense'**
  String get quick_add_expense;

  /// No description provided for @quick_add_flashcard.
  ///
  /// In en, this message translates to:
  /// **'Quick add flashcard'**
  String get quick_add_flashcard;

  /// No description provided for @quick_add_note.
  ///
  /// In en, this message translates to:
  /// **'Quick add note'**
  String get quick_add_note;

  /// No description provided for @quick_add_study.
  ///
  /// In en, this message translates to:
  /// **'Quick log study'**
  String get quick_add_study;

  /// No description provided for @quick_add_subject.
  ///
  /// In en, this message translates to:
  /// **'Quick add subject'**
  String get quick_add_subject;

  /// No description provided for @quick_add_task.
  ///
  /// In en, this message translates to:
  /// **'Quick add task'**
  String get quick_add_task;

  /// No description provided for @quick_add_topic.
  ///
  /// In en, this message translates to:
  /// **'Quick add topic'**
  String get quick_add_topic;

  /// No description provided for @quick_add_title.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get quick_add_title;

  /// No description provided for @subtasks_label.
  ///
  /// In en, this message translates to:
  /// **'Subtasks'**
  String get subtasks_label;

  /// No description provided for @teacher_optional.
  ///
  /// In en, this message translates to:
  /// **'Teacher (optional)'**
  String get teacher_optional;

  /// No description provided for @this_action_cannot_be_undone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get this_action_cannot_be_undone;

  /// No description provided for @today_tasks.
  ///
  /// In en, this message translates to:
  /// **'Today\'s tasks'**
  String get today_tasks;

  /// No description provided for @todays_progress.
  ///
  /// In en, this message translates to:
  /// **'Today\'s progress'**
  String get todays_progress;

  /// No description provided for @todays_routines.
  ///
  /// In en, this message translates to:
  /// **'Today\'s routines'**
  String get todays_routines;

  /// No description provided for @todays_study_so_far.
  ///
  /// In en, this message translates to:
  /// **'Today\'s study so far'**
  String get todays_study_so_far;

  /// No description provided for @weak_topics_section.
  ///
  /// In en, this message translates to:
  /// **'Weak topics'**
  String get weak_topics_section;

  /// No description provided for @subject_not_found_snack.
  ///
  /// In en, this message translates to:
  /// **'Subject not found'**
  String get subject_not_found_snack;

  /// No description provided for @revision_rate_weak.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get revision_rate_weak;

  /// No description provided for @revision_rate_okay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get revision_rate_okay;

  /// No description provided for @revision_rate_strong.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get revision_rate_strong;

  /// No description provided for @session_notes_optional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get session_notes_optional;

  /// No description provided for @sessions_label.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions_label;

  /// No description provided for @onboarding_name_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get onboarding_name_required;

  /// No description provided for @onboarding_class_required.
  ///
  /// In en, this message translates to:
  /// **'Please pick your class or year'**
  String get onboarding_class_required;

  /// No description provided for @onboarding_subject_required.
  ///
  /// In en, this message translates to:
  /// **'Add at least one subject'**
  String get onboarding_subject_required;

  /// No description provided for @onboarding_subject_name_required.
  ///
  /// In en, this message translates to:
  /// **'Subject name is required'**
  String get onboarding_subject_name_required;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
