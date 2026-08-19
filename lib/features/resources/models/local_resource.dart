/// Spec #27 — a reference to a local file (PDF, image, audio) attached
/// to a subject. The actual file is **not** copied; only the path is
/// stored. This keeps the app offline-first and puts the user in full
/// control of their files.
class LocalResource {
  final int? id;
  final int subjectId;
  final String title;
  final String path;
  final String? mimeType;
  final DateTime createdAt;

  const LocalResource({
    this.id,
    required this.subjectId,
    required this.title,
    required this.path,
    this.mimeType,
    required this.createdAt,
  });

  LocalResource copyWith({
    int? id,
    int? subjectId,
    String? title,
    String? path,
    String? mimeType,
    DateTime? createdAt,
  }) =>
      LocalResource(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        title: title ?? this.title,
        path: path ?? this.path,
        mimeType: mimeType ?? this.mimeType,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'subject_id': subjectId,
        'title': title,
        'path': path,
        'mime_type': mimeType,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory LocalResource.fromMap(Map<String, Object?> m) => LocalResource(
        id: m['id'] as int?,
        subjectId: m['subject_id'] as int,
        title: m['title'] as String,
        path: m['path'] as String,
        mimeType: m['mime_type'] as String?,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );
}
