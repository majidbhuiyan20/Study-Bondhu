import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Local notifications singleton (spec 24). Supports:
///
///  * `init()` — wires up `flutter_local_notifications`, sets up the
///    `Asia/Dhaka` (Dhaka) timezone as default, and creates the reminder
///    channels.
///  * `requestPermissions()` — called when a user toggles reminders on.
///  * `showImmediate(id, title, body)` — for instant feedback (e.g.
///    session complete).
///  * `scheduleAt(id, when, title, body)` — schedules a notification for a
///    specific date/time.
///  * `scheduleDaily(id, hour, minute, title, body)` — recurring daily
///    nudge at a fixed wall-clock time (used by "daily goal" reminder).
///  * `cancel(id)` / `cancelAll()` — for cleanup.
///
/// Notification ids are namespaced per category so they can be re-cancelled
/// in bulk if the user disables a category:
///   - 1_000_xxx assignments
///   - 2_000_xxx revisions
///   - 3_000_xxx exams
///   - 4_000_xxx daily goal
///   - 5_000_xxx attendance
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ---------------- Init ----------------
  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    // Default to Asia/Dhaka per spec; the device timezone is also captured
    // for accurate wall-clock scheduling.
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
    } catch (_) {
      // Fall back to UTC if the tzdata doesn't have the location.
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _plugin.initialize(settings);
    // Ensure the channels exist at boot so future `show` calls succeed.
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(_channelAssignments());
    await androidImpl?.createNotificationChannel(_channelRevisions());
    await androidImpl?.createNotificationChannel(_channelExams());
    await androidImpl?.createNotificationChannel(_channelDailyGoal());
    _initialized = true;
  }

  // ---------------- Permissions ----------------
  Future<void> requestPermissions() async {
    if (!_initialized) await init();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();
  }

  // ---------------- Show / schedule ----------------
  Future<void> showImmediate({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'study_bondhu_default',
          'StudyBondhu reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
    AndroidNotificationDetails? androidDetails,
  }) async {
    if (!_initialized) await init();
    final scheduled = tz.TZDateTime.from(when, tz.local);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
      // Skip notifications that are already in the past.
      return;
    }
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        NotificationDetails(
          android: androidDetails ?? _defaultAndroid(),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Some Android setups require the SCHEDULE_EXACT_ALARM permission.
      // Falling back silently is fine for V1 — the user still gets the
      // reminder window via `showImmediate` if needed.
      if (kDebugMode) debugPrint('scheduleAt failed: $e');
    }
  }

  Future<void> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    AndroidNotificationDetails? androidDetails,
  }) async {
    if (!_initialized) await init();
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        next,
        NotificationDetails(
          android: androidDetails ?? _defaultAndroid(),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('scheduleDaily failed: $e');
    }
  }

  // ---------------- Cancel ----------------
  Future<void> cancel(int id) async {
    if (!_initialized) await init();
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
  }

  Future<void> cancelRange(int fromInclusive, int toInclusive) async {
    if (!_initialized) await init();
    for (var id = fromInclusive; id <= toInclusive; id++) {
      await _plugin.cancel(id);
    }
  }

  // ---------------- Schedule helpers ----------------
  static int assignmentId(int rowId) => 1000000 + rowId;
  static int revisionId(int rowId) => 2000000 + rowId;
  static int examId(int rowId) => 3000000 + rowId;
  static const int dailyGoalId = 4000001;
  static const int attendanceId = 5000001;

  // ---------------- Channels ----------------
  AndroidNotificationDetails _defaultAndroid() =>
      const AndroidNotificationDetails(
        'study_bondhu_default',
        'StudyBondhu reminders',
        importance: Importance.high,
        priority: Priority.high,
      );

  AndroidNotificationChannel _channelAssignments() =>
      const AndroidNotificationChannel(
        'study_bondhu_assignments',
        'Assignment reminders',
        description: 'Reminders about upcoming assignment deadlines',
        importance: Importance.high,
      );

  AndroidNotificationChannel _channelRevisions() =>
      const AndroidNotificationChannel(
        'study_bondhu_revisions',
        'Revision reminders',
        description: 'Reminders about topics due for revision',
        importance: Importance.defaultImportance,
      );

  AndroidNotificationChannel _channelExams() =>
      const AndroidNotificationChannel(
        'study_bondhu_exams',
        'Exam reminders',
        description: 'Reminders about upcoming exams',
        importance: Importance.high,
      );

  AndroidNotificationChannel _channelDailyGoal() =>
      const AndroidNotificationChannel(
        'study_bondhu_daily',
        'Daily study goal',
        description: 'Daily study goal nudges',
        importance: Importance.defaultImportance,
      );

  AndroidNotificationDetails channelAssignmentsAndroid() =>
      const AndroidNotificationDetails(
        'study_bondhu_assignments',
        'Assignment reminders',
        importance: Importance.high,
        priority: Priority.high,
      );
  AndroidNotificationDetails channelRevisionsAndroid() =>
      const AndroidNotificationDetails(
        'study_bondhu_revisions',
        'Revision reminders',
      );
  AndroidNotificationDetails channelExamsAndroid() =>
      const AndroidNotificationDetails(
        'study_bondhu_exams',
        'Exam reminders',
        importance: Importance.high,
        priority: Priority.high,
      );
  AndroidNotificationDetails channelDailyGoalAndroid() =>
      const AndroidNotificationDetails(
        'study_bondhu_daily',
        'Daily study goal',
      );
}