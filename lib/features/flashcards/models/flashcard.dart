class FlashcardDeck {
  final int? id;
  final int? subjectId;
  final String name;
  final DateTime createdAt;

  const FlashcardDeck({
    this.id,
    this.subjectId,
    required this.name,
    required this.createdAt,
  });

  FlashcardDeck copyWith({
    int? id,
    int? subjectId,
    String? name,
    DateTime? createdAt,
  }) =>
      FlashcardDeck(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'subject_id': subjectId,
        'name': name,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory FlashcardDeck.fromMap(Map<String, Object?> m) => FlashcardDeck(
        id: m['id'] as int?,
        subjectId: m['subject_id'] as int?,
        name: m['name'] as String,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );
}

class Flashcard {
  final int? id;
  final int deckId;
  final String front;
  final String back;
  final DateTime createdAt;

  const Flashcard({
    this.id,
    required this.deckId,
    required this.front,
    required this.back,
    required this.createdAt,
  });

  Flashcard copyWith({
    int? id,
    int? deckId,
    String? front,
    String? back,
    DateTime? createdAt,
  }) =>
      Flashcard(
        id: id ?? this.id,
        deckId: deckId ?? this.deckId,
        front: front ?? this.front,
        back: back ?? this.back,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'deck_id': deckId,
        'front': front,
        'back': back,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Flashcard.fromMap(Map<String, Object?> m) => Flashcard(
        id: m['id'] as int?,
        deckId: m['deck_id'] as int,
        front: m['front'] as String,
        back: m['back'] as String,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );
}