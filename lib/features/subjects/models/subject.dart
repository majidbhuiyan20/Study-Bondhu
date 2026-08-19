class Subject {
  final int? id;
  final String name;
  final String? code;
  final double? credit;
  final String? teacher;
  final String color; // hex
  final int? semesterId;
  final double targetAttendance;
  final DateTime createdAt;

  const Subject({
    this.id,
    required this.name,
    this.code,
    this.credit,
    this.teacher,
    this.color = '#4F46E5',
    this.semesterId,
    this.targetAttendance = 75,
    required this.createdAt,
  });

  Subject copyWith({
    int? id,
    String? name,
    String? code,
    double? credit,
    String? teacher,
    String? color,
    int? semesterId,
    double? targetAttendance,
    DateTime? createdAt,
  }) =>
      Subject(
        id: id ?? this.id,
        name: name ?? this.name,
        code: code ?? this.code,
        credit: credit ?? this.credit,
        teacher: teacher ?? this.teacher,
        color: color ?? this.color,
        semesterId: semesterId ?? this.semesterId,
        targetAttendance: targetAttendance ?? this.targetAttendance,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'code': code,
        'credit': credit,
        'teacher': teacher,
        'color': color,
        'semester_id': semesterId,
        'target_attendance': targetAttendance,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Subject.fromMap(Map<String, Object?> m) => Subject(
        id: m['id'] as int?,
        name: m['name'] as String,
        code: m['code'] as String?,
        credit: (m['credit'] as num?)?.toDouble(),
        teacher: m['teacher'] as String?,
        color: (m['color'] as String?) ?? '#4F46E5',
        semesterId: m['semester_id'] as int?,
        targetAttendance:
            (m['target_attendance'] as num?)?.toDouble() ?? 75,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );
}
