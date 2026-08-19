import 'package:flutter/foundation.dart';

import '../utils/deadline_bucket.dart';
import 'notification_service.dart';

/// Spec 07 §"Reminder policy":
///
///   * Assignment due in 1 day → notify at 8 PM the day before.
///   * Exam in 3 days → notify each morning (until done / completed).
///   * User can disable per category in Settings.
///
/// This service translates a list of upcoming items into scheduled
/// notifications. The caller is responsible for refreshing the schedule
/// whenever items change (add / edit / delete / completion toggle).
class DeadlineReminderService {
  DeadlineReminderService._();

  static Future<void> scheduleForAssignment({
    required int rowId,
    required String title,
    required DateTime dueDate,
  }) async {
    final days = bucketFor(dueDate);
    if (days == DeadlineBucket.today || days == DeadlineBucket.tomorrow) {
      // Fire at 8 PM the day before the due date. For an assignment due
      // tomorrow, "the day before" is today; for a due-today item, we'd
      // be scheduling in the past, so we just fire 1 hour from now.
      final target = (days == DeadlineBucket.tomorrow)
          ? _todayAt(20, 0)
          : DateTime.now().add(const Duration(hours: 1));
      await NotificationService.instance.scheduleAt(
        id: NotificationService.assignmentId(rowId),
        when: target,
        title: 'Assignment due tomorrow',
        body: '$title is due in less than 24 hours.',
        androidDetails: NotificationService.instance
            .channelAssignmentsAndroid(),
      );
    } else {
      // Outside the 1-day window — cancel any pending reminder.
      await NotificationService.instance
          .cancel(NotificationService.assignmentId(rowId));
    }
  }

  static Future<void> scheduleForExam({
    required int rowId,
    required String title,
    required DateTime examDate,
  }) async {
    final days = bucketFor(examDate);
    if (days == DeadlineBucket.threeDays ||
        days == DeadlineBucket.sevenDays ||
        days == DeadlineBucket.later) {
      // Daily morning reminder at 8 AM until the exam date.
      final target = _todayAt(8, 0);
      await NotificationService.instance.scheduleDaily(
        id: NotificationService.examId(rowId),
        hour: target.hour,
        minute: target.minute,
        title: 'Exam coming up',
        body: '$title is on ${_short(examDate)}.',
        androidDetails:
            NotificationService.instance.channelExamsAndroid(),
      );
    } else {
      await NotificationService.instance
          .cancel(NotificationService.examId(rowId));
    }
  }

  static Future<void> cancelForAssignment(int rowId) =>
      NotificationService.instance.cancel(NotificationService.assignmentId(rowId));

  static Future<void> cancelForExam(int rowId) =>
      NotificationService.instance.cancel(NotificationService.examId(rowId));

  static DateTime _todayAt(int hour, int minute) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  static String _short(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }

  /// Best-effort batch re-scheduler. Called when the user toggles a
  /// category in Settings — pass `enabled = false` to cancel all.
  static Future<void> rescheduleAll({
    required bool assignmentsEnabled,
    required bool examsEnabled,
  }) async {
    if (!assignmentsEnabled) {
      await NotificationService.instance
          .cancelRange(1000001, 1999999);
    }
    if (!examsEnabled) {
      await NotificationService.instance.cancelRange(3000001, 3999999);
    }
    if (kDebugMode) {
      debugPrint('Deadline reminder re-schedule complete '
          '(assign=$assignmentsEnabled, exams=$examsEnabled)');
    }
  }
}
