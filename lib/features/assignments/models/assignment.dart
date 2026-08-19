enum AssignmentPriority { low, medium, high }

enum AssignmentStatus { pending, completed }

/// What kind of work is this assignment?
enum AssignmentType {
  assignment, // generic class assignment
  homework, // daily homework
  project, // long-running project
  presentation, // slides / talk
  labWork, // practical lab report
  report, // written report
}

extension AssignmentTypeX on AssignmentType {
  String get en {
    switch (this) {
      case AssignmentType.assignment:
        return 'Assignment';
      case AssignmentType.homework:
        return 'Homework';
      case AssignmentType.project:
        return 'Project';
      case AssignmentType.presentation:
        return 'Presentation';
      case AssignmentType.labWork:
        return 'Lab work';
      case AssignmentType.report:
        return 'Report';
    }
  }

  String get bn {
    switch (this) {
      case AssignmentType.assignment:
        return 'অ্যাসাইনমেন্ট';
      case AssignmentType.homework:
        return 'হোমওয়ার্ক';
      case AssignmentType.project:
        return 'প্রজেক্ট';
      case AssignmentType.presentation:
        return 'প্রেজেন্টেশন';
      case AssignmentType.labWork:
        return 'ল্যাব';
      case AssignmentType.report:
        return 'রিপোর্ট';
    }
  }

  static AssignmentType fromCode(String? raw) =>
      AssignmentType.values.firstWhere(
        (t) => t.name == raw,
        orElse: () => AssignmentType.assignment,
      );
}

class Assignment {
  final int? id;
  final int? subjectId;
  final int? topicId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final AssignmentPriority priority;
  final AssignmentStatus status;
  final DateTime? completedAt;
  final AssignmentType type;
  final int? estimatedMinutes;
  final String? notes;
  final DateTime createdAt;

  const Assignment({
    this.id,
    this.subjectId,
    this.topicId,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = AssignmentPriority.medium,
    this.status = AssignmentStatus.pending,
    this.completedAt,
    this.type = AssignmentType.assignment,
    this.estimatedMinutes,
    this.notes,
    required this.createdAt,
  });

  Assignment copyWith({
    int? id,
    int? subjectId,
    int? topicId,
    String? title,
    String? description,
    DateTime? dueDate,
    AssignmentPriority? priority,
    AssignmentStatus? status,
    DateTime? completedAt,
    AssignmentType? type,
    int? estimatedMinutes,
    String? notes,
    DateTime? createdAt,
  }) =>
      Assignment(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        topicId: topicId ?? this.topicId,
        title: title ?? this.title,
        description: description ?? this.description,
        dueDate: dueDate ?? this.dueDate,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        completedAt: completedAt ?? this.completedAt,
        type: type ?? this.type,
        estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'subject_id': subjectId,
        'topic_id': topicId,
        'title': title,
        'description': description,
        'due_date': dueDate?.millisecondsSinceEpoch,
        'priority': priority.name,
        'status': status.name,
        'completed_at': completedAt?.millisecondsSinceEpoch,
        'type': type.name,
        'estimated_minutes': estimatedMinutes,
        'notes': notes,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Assignment.fromMap(Map<String, Object?> m) => Assignment(
        id: m['id'] as int?,
        subjectId: m['subject_id'] as int?,
        topicId: m['topic_id'] as int?,
        title: m['title'] as String,
        description: m['description'] as String?,
        dueDate: m['due_date'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(m['due_date'] as int),
        priority: AssignmentPriority.values.firstWhere(
          (p) => p.name == (m['priority'] as String? ?? 'medium'),
          orElse: () => AssignmentPriority.medium,
        ),
        status: AssignmentStatus.values.firstWhere(
          (p) => p.name == (m['status'] as String? ?? 'pending'),
          orElse: () => AssignmentStatus.pending,
        ),
        completedAt: m['completed_at'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(m['completed_at'] as int),
        type: AssignmentTypeX.fromCode(m['type'] as String?),
        estimatedMinutes: m['estimated_minutes'] as int?,
        notes: m['notes'] as String?,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );
}