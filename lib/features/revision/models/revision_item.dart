enum RevisionStatus { pending, completed, missed }

class RevisionItem {
  final int? id;
  final int? subjectId;
  final int? topicId;
  final DateTime scheduledDate;
  final RevisionStatus status;
  final int intervalDays;
  final DateTime createdAt;

  const RevisionItem({
    this.id,
    this.subjectId,
    this.topicId,
    required this.scheduledDate,
    this.status = RevisionStatus.pending,
    this.intervalDays = 1,
    required this.createdAt,
  });

  RevisionItem copyWith({
    int? id,
    int? subjectId,
    int? topicId,
    DateTime? scheduledDate,
    RevisionStatus? status,
    int? intervalDays,
    DateTime? createdAt,
  }) =>
      RevisionItem(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        topicId: topicId ?? this.topicId,
        scheduledDate: scheduledDate ?? this.scheduledDate,
        status: status ?? this.status,
        intervalDays: intervalDays ?? this.intervalDays,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'subject_id': subjectId,
        'topic_id': topicId,
        'scheduled_date': scheduledDate.millisecondsSinceEpoch,
        'status': status.name,
        'interval_days': intervalDays,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory RevisionItem.fromMap(Map<String, Object?> m) => RevisionItem(
        id: m['id'] as int?,
        subjectId: m['subject_id'] as int?,
        topicId: m['topic_id'] as int?,
        scheduledDate:
            DateTime.fromMillisecondsSinceEpoch(m['scheduled_date'] as int),
        status: RevisionStatus.values.firstWhere(
          (p) => p.name == (m['status'] as String? ?? 'pending'),
          orElse: () => RevisionStatus.pending,
        ),
        intervalDays: m['interval_days'] as int? ?? 1,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );
}