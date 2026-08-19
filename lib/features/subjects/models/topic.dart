/// Topic lifecycle status, used by the Subject Details tab, Weakness Radar,
/// and revision→topic confidence flow.
///
/// notStarted → learning → weak / mastered are user-driven transitions;
/// weak/mastered can also be derived from session focus ratings (see 13).
enum TopicStatus { notStarted, learning, weak, mastered }

extension TopicStatusX on TopicStatus {
  String get en {
    switch (this) {
      case TopicStatus.notStarted:
        return 'Not started';
      case TopicStatus.learning:
        return 'Learning';
      case TopicStatus.weak:
        return 'Weak';
      case TopicStatus.mastered:
        return 'Mastered';
    }
  }

  String get bn {
    switch (this) {
      case TopicStatus.notStarted:
        return 'শুরু হয়নি';
      case TopicStatus.learning:
        return 'শিখছি';
      case TopicStatus.weak:
        return 'দুর্বল';
      case TopicStatus.mastered:
        return 'দক্ষ';
    }
  }

  /// Code used in DB column and widget choose flows.
  String get code => name;

  static TopicStatus fromCode(String? raw) {
    if (raw == null) return TopicStatus.notStarted;
    return TopicStatus.values.firstWhere(
      (t) => t.name == raw,
      orElse: () => TopicStatus.notStarted,
    );
  }
}

class Topic {
  final int? id;
  final String name;
  final int subjectId;
  final bool isCompleted;
  final int confidence; // 1..5 — kept for backwards compat; status is canonical
  final int order;
  final int? parentId; // null = top-level topic; else = sub-topic
  final TopicStatus status;
  final DateTime createdAt;

  const Topic({
    this.id,
    required this.name,
    required this.subjectId,
    this.isCompleted = false,
    this.confidence = 3,
    this.order = 0,
    this.parentId,
    this.status = TopicStatus.notStarted,
    required this.createdAt,
  });

  Topic copyWith({
    int? id,
    String? name,
    int? subjectId,
    bool? isCompleted,
    int? confidence,
    int? order,
    int? parentId,
    TopicStatus? status,
    DateTime? createdAt,
  }) =>
      Topic(
        id: id ?? this.id,
        name: name ?? this.name,
        subjectId: subjectId ?? this.subjectId,
        isCompleted: isCompleted ?? this.isCompleted,
        confidence: confidence ?? this.confidence,
        order: order ?? this.order,
        parentId: parentId ?? this.parentId,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'subject_id': subjectId,
        'is_completed': isCompleted ? 1 : 0,
        'confidence': confidence,
        'sort_order': order,
        'parent_id': parentId,
        'status': status.code,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Topic.fromMap(Map<String, Object?> m) => Topic(
        id: m['id'] as int?,
        name: m['name'] as String,
        subjectId: m['subject_id'] as int,
        isCompleted: (m['is_completed'] as int? ?? 0) == 1,
        confidence: m['confidence'] as int? ?? 3,
        order: m['sort_order'] as int? ?? 0,
        parentId: m['parent_id'] as int?,
        status: TopicStatusX.fromCode(m['status'] as String?),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );
}