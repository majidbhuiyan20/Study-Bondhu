/// A recurring assignment that fires on specific weekdays.
class Routine {
  final int? id;
  final int? subjectId;
  final String title;
  final List<int> daysOfWeek; // 1=Mon..7=Sun
  final String? timeOfDay; // e.g. "After school"
  final String? notes;
  final bool isActive;
  final DateTime? lastDone;
  final DateTime createdAt;

  const Routine({
    this.id,
    this.subjectId,
    required this.title,
    this.daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
    this.timeOfDay,
    this.notes,
    this.isActive = true,
    this.lastDone,
    required this.createdAt,
  });

  bool isOnDay(DateTime day) => daysOfWeek.contains(day.weekday);

  Routine copyWith({
    int? id,
    int? subjectId,
    String? title,
    List<int>? daysOfWeek,
    String? timeOfDay,
    String? notes,
    bool? isActive,
    DateTime? lastDone,
    DateTime? createdAt,
  }) =>
      Routine(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        title: title ?? this.title,
        daysOfWeek: daysOfWeek ?? this.daysOfWeek,
        timeOfDay: timeOfDay ?? this.timeOfDay,
        notes: notes ?? this.notes,
        isActive: isActive ?? this.isActive,
        lastDone: lastDone ?? this.lastDone,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'subject_id': subjectId,
        'title': title,
        'days_of_week': daysOfWeek.join(','),
        'time_of_day': timeOfDay,
        'notes': notes,
        'is_active': isActive ? 1 : 0,
        'last_done_date': lastDone?.millisecondsSinceEpoch,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Routine.fromMap(Map<String, Object?> m) => Routine(
        id: m['id'] as int?,
        subjectId: m['subject_id'] as int?,
        title: m['title'] as String,
        daysOfWeek: ((m['days_of_week'] as String?) ?? '1,2,3,4,5,6,7')
            .split(',')
            .where((s) => s.isNotEmpty)
            .map(int.parse)
            .toList(),
        timeOfDay: m['time_of_day'] as String?,
        notes: m['notes'] as String?,
        isActive: (m['is_active'] as int? ?? 1) == 1,
        lastDone: m['last_done_date'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(m['last_done_date'] as int),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );
}

const weekdayShortEn = {
  1: 'Mon',
  2: 'Tue',
  3: 'Wed',
  4: 'Thu',
  5: 'Fri',
  6: 'Sat',
  7: 'Sun',
};

const weekdayShortBn = {
  1: 'সোম',
  2: 'মঙ্গল',
  3: 'বুধ',
  4: 'বৃহঃ',
  5: 'শুক্র',
  6: 'শনি',
  7: 'রবি',
};