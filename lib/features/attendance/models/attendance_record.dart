enum AttendanceStatus { present, absent, late }

class AttendanceRecord {
  final int? id;
  final int subjectId;
  final DateTime date;
  final AttendanceStatus status;
  final String? note;
  final DateTime createdAt;

  const AttendanceRecord({
    this.id,
    required this.subjectId,
    required this.date,
    this.status = AttendanceStatus.present,
    this.note,
    required this.createdAt,
  });

  AttendanceRecord copyWith({
    int? id,
    int? subjectId,
    DateTime? date,
    AttendanceStatus? status,
    String? note,
    DateTime? createdAt,
  }) =>
      AttendanceRecord(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        date: date ?? this.date,
        status: status ?? this.status,
        note: note ?? this.note,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'subject_id': subjectId,
        'date': date.millisecondsSinceEpoch,
        'status': status.name,
        'note': note,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory AttendanceRecord.fromMap(Map<String, Object?> m) =>
      AttendanceRecord(
        id: m['id'] as int?,
        subjectId: m['subject_id'] as int,
        date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
        status: AttendanceStatus.values.firstWhere(
          (p) => p.name == (m['status'] as String? ?? 'present'),
          orElse: () => AttendanceStatus.present,
        ),
        note: m['note'] as String?,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );
}