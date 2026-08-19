enum GoalType { daily, weekly, total }

class Goal {
  final int? id;
  final String title;
  final GoalType type;
  final int target;
  final int progress;
  final DateTime createdAt;

  const Goal({
    this.id,
    required this.title,
    this.type = GoalType.daily,
    required this.target,
    this.progress = 0,
    required this.createdAt,
  });

  double get percent => target == 0 ? 0 : progress / target;

  Goal copyWith({
    int? id,
    String? title,
    GoalType? type,
    int? target,
    int? progress,
    DateTime? createdAt,
  }) =>
      Goal(
        id: id ?? this.id,
        title: title ?? this.title,
        type: type ?? this.type,
        target: target ?? this.target,
        progress: progress ?? this.progress,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'type': type.name,
        'target': target,
        'progress': progress,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Goal.fromMap(Map<String, Object?> m) => Goal(
        id: m['id'] as int?,
        title: m['title'] as String,
        type: GoalType.values.firstWhere(
          (p) => p.name == (m['type'] as String? ?? 'daily'),
          orElse: () => GoalType.daily,
        ),
        target: m['target'] as int,
        progress: m['progress'] as int? ?? 0,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );
}