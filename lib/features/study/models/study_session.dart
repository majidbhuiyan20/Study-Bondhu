enum StudyMode { focus, pomodoro, free }

class StudySession {
  final int? id;
  final int? subjectId;
  final int? topicId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final String? notes;
  final int focusRating; // 1..5
  final StudyMode mode;
  final DateTime createdAt;

  const StudySession({
    this.id,
    this.subjectId,
    this.topicId,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    this.notes,
    this.focusRating = 3,
    this.mode = StudyMode.focus,
    required this.createdAt,
  });

  Duration get duration => Duration(seconds: durationSeconds);

  StudySession copyWith({
    int? id,
    int? subjectId,
    int? topicId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    String? notes,
    int? focusRating,
    StudyMode? mode,
    DateTime? createdAt,
  }) =>
      StudySession(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        topicId: topicId ?? this.topicId,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        notes: notes ?? this.notes,
        focusRating: focusRating ?? this.focusRating,
        mode: mode ?? this.mode,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'subject_id': subjectId,
        'topic_id': topicId,
        'start_time': startTime.millisecondsSinceEpoch,
        'end_time': endTime.millisecondsSinceEpoch,
        'duration_seconds': durationSeconds,
        'notes': notes,
        'focus_rating': focusRating,
        'mode': mode.name,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory StudySession.fromMap(Map<String, Object?> m) => StudySession(
        id: m['id'] as int?,
        subjectId: m['subject_id'] as int?,
        topicId: m['topic_id'] as int?,
        startTime:
            DateTime.fromMillisecondsSinceEpoch(m['start_time'] as int),
        endTime: DateTime.fromMillisecondsSinceEpoch(m['end_time'] as int),
        durationSeconds: m['duration_seconds'] as int,
        notes: m['notes'] as String?,
        focusRating: m['focus_rating'] as int? ?? 3,
        mode: StudyMode.values.firstWhere(
          (p) => p.name == (m['mode'] as String? ?? 'focus'),
          orElse: () => StudyMode.focus,
        ),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );
}