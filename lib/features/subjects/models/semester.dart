class Semester {
  final int? id;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final int? profileId;
  final DateTime createdAt;

  const Semester({
    this.id,
    required this.name,
    this.startDate,
    this.endDate,
    this.isActive = false,
    this.profileId,
    required this.createdAt,
  });

  Semester copyWith({
    int? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? profileId,
    DateTime? createdAt,
  }) =>
      Semester(
        id: id ?? this.id,
        name: name ?? this.name,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        isActive: isActive ?? this.isActive,
        profileId: profileId ?? this.profileId,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'start_date': startDate?.millisecondsSinceEpoch,
        'end_date': endDate?.millisecondsSinceEpoch,
        'is_active': isActive ? 1 : 0,
        'profile_id': profileId,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Semester.fromMap(Map<String, Object?> m) => Semester(
        id: m['id'] as int?,
        name: m['name'] as String,
        startDate: m['start_date'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(m['start_date'] as int),
        endDate: m['end_date'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(m['end_date'] as int),
        isActive: (m['is_active'] as int? ?? 0) == 1,
        profileId: m['profile_id'] as int?,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );
}
