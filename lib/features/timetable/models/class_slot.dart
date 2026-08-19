/// Spec #26 — weekly class timetable slot.
///
/// `dayOfWeek` follows `DateTime.weekday` semantics: 1=Mon..7=Sun.
/// `startTime` / `endTime` are stored as `"HH:mm"` 24-hour strings so the
/// app can format them per-locale without needing timezone-aware parsing.
class ClassSlot {
  final int? id;
  final int subjectId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String? location;
  final DateTime createdAt;

  const ClassSlot({
    this.id,
    required this.subjectId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.location,
    required this.createdAt,
  });

  ClassSlot copyWith({
    int? id,
    int? subjectId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? location,
    DateTime? createdAt,
  }) =>
      ClassSlot(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        location: location ?? this.location,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'subject_id': subjectId,
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'location': location,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory ClassSlot.fromMap(Map<String, Object?> m) => ClassSlot(
        id: m['id'] as int?,
        subjectId: m['subject_id'] as int,
        dayOfWeek: m['day_of_week'] as int,
        startTime: m['start_time'] as String,
        endTime: m['end_time'] as String,
        location: m['location'] as String?,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );

  /// Returns the slot's start minutes-since-midnight for sorting.
  int get startMinutes {
    final parts = startTime.split(':');
    if (parts.length < 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 +
        (int.tryParse(parts[1]) ?? 0);
  }
}
