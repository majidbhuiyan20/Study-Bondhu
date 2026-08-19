/// A smaller piece of work that contributes to an [Assignment]'s
/// overall [progress]. Spec 06 §"Subtasks".
class AssignmentSubtask {
  final int? id;
  final int assignmentId;
  final String title;
  final bool isDone;
  final int orderIndex;

  const AssignmentSubtask({
    this.id,
    required this.assignmentId,
    required this.title,
    this.isDone = false,
    this.orderIndex = 0,
  });

  AssignmentSubtask copyWith({
    int? id,
    int? assignmentId,
    String? title,
    bool? isDone,
    int? orderIndex,
  }) =>
      AssignmentSubtask(
        id: id ?? this.id,
        assignmentId: assignmentId ?? this.assignmentId,
        title: title ?? this.title,
        isDone: isDone ?? this.isDone,
        orderIndex: orderIndex ?? this.orderIndex,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'assignment_id': assignmentId,
        'title': title,
        'is_done': isDone ? 1 : 0,
        'order_index': orderIndex,
      };

  factory AssignmentSubtask.fromMap(Map<String, Object?> m) =>
      AssignmentSubtask(
        id: m['id'] as int?,
        assignmentId: m['assignment_id'] as int,
        title: m['title'] as String,
        isDone: (m['is_done'] as int? ?? 0) == 1,
        orderIndex: m['order_index'] as int? ?? 0,
      );
}
