import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/revision/models/revision_item.dart';
import '../providers.dart';
import 'notification_service.dart';

/// Schedule all upcoming notifications. Called at app start (after auth
/// and DB init) and whenever the user toggles notifications on.
///
/// Reads from the repositories directly — we want scheduling to be
/// deterministic at boot and not depend on UI state.
class NotificationScheduler {
  NotificationScheduler(this._ref);
  final Ref _ref;

  Future<void> scheduleAll() async {
    final storage = _ref.read(localStorageProvider);
    if (!storage.notificationsEnabled) {
      await NotificationService.instance.cancelAll();
      return;
    }
    final notif = NotificationService.instance;

    // Cancel everything we own first so we never have stale reminders,
    // and so disabled categories don't leave remnants behind.
    await notif.cancelAll();

    final studyGoalMinutes = storage.dailyGoalMinutes;
    final locale = Locale(storage.locale);

    // ----- Daily goal: 8 PM nudge -----
    if (storage.notifDailyGoal) {
      await notif.scheduleDaily(
        id: NotificationService.dailyGoalId,
        hour: 20,
        minute: 0,
        title: _l(locale, 'Daily goal not met yet',
            'আজকের লক্ষ্য এখনো পূরণ হয়নি'),
        body: _l(
          locale,
          'Study $studyGoalMinutes minutes today to keep your streak.',
          'স্ট্রিক ধরে রাখতে আজ $studyGoalMinutes মিনিট পড়ুন।',
        ),
        androidDetails: notif.channelDailyGoalAndroid(),
      );
    }

    // ----- Assignments -----
    if (storage.notifAssignments) {
      final assignmentsRepo = _ref.read(assignmentsRepositoryProvider);
      final assignments = await assignmentsRepo.getAssignments();
      for (final a in assignments) {
        if (a.dueDate == null || a.id == null) continue;
        final when = DateTime(
          a.dueDate!.year,
          a.dueDate!.month,
          a.dueDate!.day,
        ).subtract(const Duration(days: 1));
        final fireAt = DateTime(when.year, when.month, when.day, 20, 0);
        await notif.scheduleAt(
          id: NotificationService.assignmentId(a.id!),
          when: fireAt,
          title: _l(locale, 'Assignment due tomorrow',
              'অ্যাসাইনমেন্ট আগামীকালের মধ্যে'),
          body: a.title,
          androidDetails: notif.channelAssignmentsAndroid(),
        );
      }
    }

    // ----- Exams -----
    if (storage.notifExams) {
      final examsRepo = _ref.read(examsRepositoryProvider);
      final exams = await examsRepo.getExams();
      final subjectsRepo = _ref.read(subjectsRepositoryProvider);
      final subjects = await subjectsRepo.getSubjects();
      String subjectName(int? id) {
        if (id == null) return '';
        for (final s in subjects) {
          if (s.id == id) return s.name;
        }
        return '';
      }

      for (final e in exams) {
        if (e.id == null) continue;
        final days = e.examDate.difference(DateTime.now()).inDays;
        if (days == 1 || days == 3 || days == 7) {
          final fireAt = DateTime(
            e.examDate.year,
            e.examDate.month,
            e.examDate.day,
            8,
            0,
          ).subtract(Duration(days: days));
          await notif.scheduleAt(
            id: NotificationService.examId(e.id!),
            when: fireAt,
            title: _l(locale, 'Exam in $days day${days == 1 ? "" : "s"}',
                'পরীক্ষা আর $days দিনে'),
            body:
                '${e.title}${subjectName(e.subjectId).isNotEmpty ? " • ${subjectName(e.subjectId)}" : ""}',
            androidDetails: notif.channelExamsAndroid(),
          );
        }
      }
    }

    // ----- Revisions (morning of the due day) -----
    if (storage.notifRevisions) {
      final revisionsRepo = _ref.read(revisionRepositoryProvider);
      final revisions = await revisionsRepo.getAll();
      for (final r in revisions) {
        if (r.id == null) continue;
        if (r.status != RevisionStatus.pending) continue;
        final fireAt = DateTime(
          r.scheduledDate.year,
          r.scheduledDate.month,
          r.scheduledDate.day,
          8,
          0,
        );
        await notif.scheduleAt(
          id: NotificationService.revisionId(r.id!),
          when: fireAt,
          title: _l(locale, 'Revision due today', 'আজ রিভিশন আছে'),
          body: _l(locale, 'Open StudyBondhu and review the topic.',
              'স্টাডি বন্ধু খুলে টপিক রিভিশন করুন।'),
          androidDetails: notif.channelRevisionsAndroid(),
        );
      }
    }

    // ----- Attendance alerts (place-holder for future implementation) -----
    // The spec mentions a category but the analytics/attendance side
    // does not yet compute per-subject drops below target. We still
    // schedule a no-op so the toggle is respected and persists.
    if (storage.notifAttendance) {
      // When attendance alerts are wired up, fire here. For now the
      // category exists but does not schedule anything.
    }
  }
}

final notificationSchedulerProvider = Provider<NotificationScheduler>(
  (ref) => NotificationScheduler(ref),
);

String _l(Locale locale, String en, String bn) =>
    locale.languageCode == 'bn' ? bn : en;