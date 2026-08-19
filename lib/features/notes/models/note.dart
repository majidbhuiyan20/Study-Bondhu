class Note {
  final int? id;
  final int? subjectId;
  final int? topicId;
  final String title;
  final String body;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    this.id,
    this.subjectId,
    this.topicId,
    required this.title,
    required this.body,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    int? id,
    int? subjectId,
    int? topicId,
    String? title,
    String? body,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Note(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        topicId: topicId ?? this.topicId,
        title: title ?? this.title,
        body: body ?? this.body,
        isPinned: isPinned ?? this.isPinned,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'subject_id': subjectId,
        'topic_id': topicId,
        'title': title,
        'body': body,
        'is_pinned': isPinned ? 1 : 0,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };

  factory Note.fromMap(Map<String, Object?> m) => Note(
        id: m['id'] as int?,
        subjectId: m['subject_id'] as int?,
        topicId: m['topic_id'] as int?,
        title: m['title'] as String,
        body: m['body'] as String,
        isPinned: (m['is_pinned'] as int? ?? 0) == 1,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
        updatedAt:
            DateTime.fromMillisecondsSinceEpoch(m['updated_at'] as int),
      );
}