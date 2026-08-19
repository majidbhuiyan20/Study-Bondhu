/// Educational stage / institution a student is studying in.
enum ProfileLevel { school, college, university, madrasa, coaching }

extension ProfileLevelX on ProfileLevel {
  String get en {
    switch (this) {
      case ProfileLevel.school:
        return 'School';
      case ProfileLevel.college:
        return 'College';
      case ProfileLevel.university:
        return 'University';
      case ProfileLevel.madrasa:
        return 'Madrasa';
      case ProfileLevel.coaching:
        return 'Coaching';
    }
  }

  String get bn {
    switch (this) {
      case ProfileLevel.school:
        return 'স্কুল';
      case ProfileLevel.college:
        return 'কলেজ';
      case ProfileLevel.university:
        return 'বিশ্ববিদ্যালয়';
      case ProfileLevel.madrasa:
        return 'মাদ্রাসা';
      case ProfileLevel.coaching:
        return 'কোচিং';
    }
  }

  /// Class / grade options appropriate for this level.
  List<String> get classOptions {
    switch (this) {
      case ProfileLevel.school:
        return [
          'Class 6',
          'Class 7',
          'Class 8',
          'Class 9',
          'Class 10',
          'SSC Batch',
        ];
      case ProfileLevel.college:
        return [
          'HSC 1st Year',
          'HSC 2nd Year',
          'HSC Batch',
        ];
      case ProfileLevel.university:
        return [
          'Year 1',
          'Year 2',
          'Year 3',
          'Year 4',
          'Masters',
        ];
      case ProfileLevel.madrasa:
        return [
          'Class 6 (Dakhil)',
          'Class 7',
          'Class 8',
          'Class 9',
          'Class 10 (Dakhil)',
          'Class 11 (Alim 1st Year)',
          'Class 12 (Alim 2nd Year)',
        ];
      case ProfileLevel.coaching:
        return [
          'SSC Prep',
          'HSC Prep',
          'Admission Prep',
          'BCS Prep',
        ];
    }
  }
}

class Profile {
  final int? id;
  final String name;
  final ProfileLevel level;
  final String? classLabel; // e.g. "Class 10", "HSC 2nd Year"
  final String? institution; // e.g. "Dhaka College"
  final String? department; // e.g. "CSE"
  final String? studentId; // roll / registration number
  final DateTime createdAt;

  const Profile({
    this.id,
    required this.name,
    this.level = ProfileLevel.school,
    this.classLabel,
    this.institution,
    this.department,
    this.studentId,
    required this.createdAt,
  });

  Profile copyWith({
    int? id,
    String? name,
    ProfileLevel? level,
    String? classLabel,
    String? institution,
    String? department,
    String? studentId,
    DateTime? createdAt,
  }) =>
      Profile(
        id: id ?? this.id,
        name: name ?? this.name,
        level: level ?? this.level,
        classLabel: classLabel ?? this.classLabel,
        institution: institution ?? this.institution,
        department: department ?? this.department,
        studentId: studentId ?? this.studentId,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'level': level.name,
        'class_label': classLabel,
        'institution': institution,
        'department': department,
        'student_id': studentId,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Profile.fromMap(Map<String, Object?> m) => Profile(
        id: m['id'] as int?,
        name: m['name'] as String,
        level: ProfileLevel.values.firstWhere(
          (l) => l.name == (m['level'] as String? ?? 'school'),
          orElse: () => ProfileLevel.school,
        ),
        classLabel: m['class_label'] as String?,
        institution: m['institution'] as String?,
        department: m['department'] as String?,
        studentId: m['student_id'] as String?,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );
}