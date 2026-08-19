/// Bucketing used across assignments, exams, and notifications (spec 07).
/// Buckets the absolute day-until value into named categories so the UI
/// can colour-code urgency consistently.
enum DeadlineBucket {
  overdue, // < 0 days (past due)
  today, // == 0
  tomorrow, // == 1
  threeDays, // 2..3
  sevenDays, // 4..7
  later, // > 7
  none, // no date set
}

extension DeadlineBucketX on DeadlineBucket {
  // Hex palette mirrors the spec 07 table:
  //   today / tomorrow: red, 3 days: amber, 7 days: green, later: gray.
  static const Map<DeadlineBucket, int> _palette = {
    DeadlineBucket.overdue: 0xFFEF4444,
    DeadlineBucket.today: 0xFFEF4444,
    DeadlineBucket.tomorrow: 0xFFEF4444,
    DeadlineBucket.threeDays: 0xFFF59E0B,
    DeadlineBucket.sevenDays: 0xFF22C55E,
    DeadlineBucket.later: 0xFF9CA3AF,
    DeadlineBucket.none: 0xFF9CA3AF,
  };

  int get hex => _palette[this] ?? 0xFF6B7280;

  String enLabel() {
    switch (this) {
      case DeadlineBucket.overdue:
        return 'Overdue';
      case DeadlineBucket.today:
        return 'Today';
      case DeadlineBucket.tomorrow:
        return 'Tomorrow';
      case DeadlineBucket.threeDays:
        return 'In 3 days';
      case DeadlineBucket.sevenDays:
        return 'This week';
      case DeadlineBucket.later:
        return 'Later';
      case DeadlineBucket.none:
        return 'No date';
    }
  }

  String bnLabel() {
    switch (this) {
      case DeadlineBucket.overdue:
        return 'মেয়াদোত্তীর্ণ';
      case DeadlineBucket.today:
        return 'আজ';
      case DeadlineBucket.tomorrow:
        return 'আগামীকাল';
      case DeadlineBucket.threeDays:
        return '৩ দিনে';
      case DeadlineBucket.sevenDays:
        return 'এই সপ্তাহে';
      case DeadlineBucket.later:
        return 'পরে';
      case DeadlineBucket.none:
        return 'তারিখ নেই';
    }
  }
}

/// Resolve a [DeadlineBucket] for a given [date]. Returns [DeadlineBucket.none]
/// if [date] is null.
DeadlineBucket bucketFor(DateTime? date, {DateTime? now}) {
  if (date == null) return DeadlineBucket.none;
  final ref = now ?? DateTime.now();
  final today = DateTime(ref.year, ref.month, ref.day);
  final target = DateTime(date.year, date.month, date.day);
  final days = target.difference(today).inDays;
  if (days < 0) return DeadlineBucket.overdue;
  if (days == 0) return DeadlineBucket.today;
  if (days == 1) return DeadlineBucket.tomorrow;
  if (days <= 3) return DeadlineBucket.threeDays;
  if (days <= 7) return DeadlineBucket.sevenDays;
  return DeadlineBucket.later;
}