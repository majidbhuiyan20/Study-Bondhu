class SyllabusItem {
  final int? id;
  final int subjectId;
  final String title;
  final String? description;
  final bool isDone;
  final int orderIndex;
  final DateTime? completedAt;
  final DateTime createdAt;

  const SyllabusItem({
    this.id,
    required this.subjectId,
    required this.title,
    this.description,
    this.isDone = false,
    this.orderIndex = 0,
    this.completedAt,
    required this.createdAt,
  });

  SyllabusItem copyWith({
    int? id,
    int? subjectId,
    String? title,
    String? description,
    bool? isDone,
    int? orderIndex,
    DateTime? completedAt,
    DateTime? createdAt,
  }) =>
      SyllabusItem(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        title: title ?? this.title,
        description: description ?? this.description,
        isDone: isDone ?? this.isDone,
        orderIndex: orderIndex ?? this.orderIndex,
        completedAt: completedAt ?? this.completedAt,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'subject_id': subjectId,
        'title': title,
        'description': description,
        'is_done': isDone ? 1 : 0,
        'order_index': orderIndex,
        'completed_at': completedAt?.millisecondsSinceEpoch,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory SyllabusItem.fromMap(Map<String, Object?> m) => SyllabusItem(
        id: m['id'] as int?,
        subjectId: m['subject_id'] as int,
        title: m['title'] as String,
        description: m['description'] as String?,
        isDone: (m['is_done'] as int? ?? 0) == 1,
        orderIndex: m['order_index'] as int? ?? 0,
        completedAt: m['completed_at'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(m['completed_at'] as int),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );
}