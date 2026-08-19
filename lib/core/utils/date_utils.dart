import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static DateTime get today => _stripTime(DateTime.now());

  static DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime startOfWeek(DateTime date) {
    final d = _stripTime(date);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  static DateTime endOfWeek(DateTime date) {
    return startOfWeek(date).add(const Duration(days: 6));
  }

  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static int daysUntil(DateTime target) {
    final t = _stripTime(target);
    return t.difference(today).inDays;
  }

  static String formatDate(DateTime date, {String pattern = 'MMM d, y'}) =>
      DateFormat(pattern).format(date);

  static String formatShort(DateTime date) =>
      DateFormat('MMM d').format(date);

  static String formatWeekday(DateTime date) =>
      DateFormat('EEE').format(date);

  static String formatMonthDay(DateTime date) =>
      DateFormat('MMM d').format(date);

  static String relative(DateTime date) {
    final diff = today.difference(_stripTime(date)).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff == -1) return 'Tomorrow';
    if (diff > 1 && diff < 7) return '$diff days ago';
    if (diff < -1 && diff > -7) return 'In ${-diff} days';
    return formatDate(date);
  }

  static String relativeBanglaHint(DateTime date) {
    final diff = daysUntil(date);
    if (diff == 0) return 'আজ';
    if (diff == 1) return 'আগামীকাল';
    if (diff > 1) return 'আর $diff দিন';
    if (diff == -1) return 'গতকাল';
    if (diff < -1) return '$diff দিন আগে';
    return formatDate(date);
  }
}
