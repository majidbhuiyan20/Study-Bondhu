enum ExamType { midterm, finalExam, quiz, other }

class Exam {
  final int? id;
  final int? subjectId;
  final String title;
  final DateTime examDate;
  final DateTime? startTime;
  final String? time; // "09:00 – 11:00"
  final String? location;
  final ExamType type;
  final String? syllabus;
  final String? notes;
  final double? totalMarks;
  final double? obtainedMarks;
  final DateTime createdAt;

  const Exam({
    this.id,
    this.subjectId,
    required this.title,
    required this.examDate,
    this.startTime,
    this.time,
    this.location,
    this.type = ExamType.midterm,
    this.syllabus,
    this.notes,
    this.totalMarks,
    this.obtainedMarks,
    required this.createdAt,
  });

  Exam copyWith({
    int? id,
    int? subjectId,
    String? title,
    DateTime? examDate,
    DateTime? startTime,
    String? time,
    String? location,
    ExamType? type,
    String? syllabus,
    String? notes,
    double? totalMarks,
    double? obtainedMarks,
    DateTime? createdAt,
  }) =>
      Exam(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        title: title ?? this.title,
        examDate: examDate ?? this.examDate,
        startTime: startTime ?? this.startTime,
        time: time ?? this.time,
        location: location ?? this.location,
        type: type ?? this.type,
        syllabus: syllabus ?? this.syllabus,
        notes: notes ?? this.notes,
        totalMarks: totalMarks ?? this.totalMarks,
        obtainedMarks: obtainedMarks ?? this.obtainedMarks,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'subject_id': subjectId,
        'title': title,
        'exam_date': examDate.millisecondsSinceEpoch,
        'start_time': startTime?.millisecondsSinceEpoch,
        'time': time,
        'location': location,
        'type': type.name,
        'syllabus': syllabus,
        'notes': notes,
        'total_marks': totalMarks,
        'obtained_marks': obtainedMarks,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Exam.fromMap(Map<String, Object?> m) => Exam(
        id: m['id'] as int?,
        subjectId: m['subject_id'] as int?,
        title: m['title'] as String,
        examDate:
            DateTime.fromMillisecondsSinceEpoch(m['exam_date'] as int),
        startTime: m['start_time'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(m['start_time'] as int),
        time: m['time'] as String?,
        location: m['location'] as String?,
        type: ExamType.values.firstWhere(
          (p) => p.name == (m['type'] as String? ?? 'midterm'),
          orElse: () => ExamType.midterm,
        ),
        syllabus: m['syllabus'] as String?,
        notes: m['notes'] as String?,
        totalMarks: (m['total_marks'] as num?)?.toDouble(),
        obtainedMarks: (m['obtained_marks'] as num?)?.toDouble(),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );

  bool get isPast => examDate.isBefore(DateTime.now());
}