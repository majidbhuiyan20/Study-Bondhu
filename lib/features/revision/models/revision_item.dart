enum RevisionStatus { pending, completed, missed }

/// Allowed 3-state rating values. Anything outside this set is rejected by
/// the view model and repository.
const Set<int> kRevisionRatings = {1, 3, 5};

class RevisionItem {
  final int? id;
  final int? subjectId;
  final int? topicId;
  final DateTime scheduledDate;
  final RevisionStatus status;
  final int intervalDays;
  final int? rating; // 1=weak / 3=okay / 5=strong; null = not yet rated
  final DateTime createdAt;

  const RevisionItem({
    this.id,
    this.subjectId,
    this.topicId,
    required this.scheduledDate,
    this.status = RevisionStatus.pending,
    this.intervalDays = 1,
    this.rating,
    required this.createdAt,
  });

  RevisionItem copyWith({
    int? id,
    int? subjectId,
    int? topicId,
    DateTime? scheduledDate,
    RevisionStatus? status,
    int? intervalDays,
    int? rating,
    DateTime? createdAt,
    bool clearRating = false,
  }) =>
      RevisionItem(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        topicId: topicId ?? this.topicId,
        scheduledDate: scheduledDate ?? this.scheduledDate,
        status: status ?? this.status,
        intervalDays: intervalDays ?? this.intervalDays,
        rating: clearRating ? null : (rating ?? this.rating),
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'subject_id': subjectId,
        'topic_id': topicId,
        'scheduled_date': scheduledDate.millisecondsSinceEpoch,
        'status': status.name,
        'interval_days': intervalDays,
        'rating': rating,
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
        // Defensive parse: a malformed rating from older DB rows must not
        // crash the UI. Clamp to one of the allowed values when possible,
        // otherwise null.
        rating: _parseRating(m['rating']),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );

  static int? _parseRating(Object? raw) {
    if (raw is int && kRevisionRatings.contains(raw)) return raw;
    if (raw is String) {
      final n = int.tryParse(raw);
      if (n != null && kRevisionRatings.contains(n)) return n;
    }
    return null;
  }
}