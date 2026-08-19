import '../../../database/app_database.dart';
import '../../../database/database_tables.dart';
import '../models/flashcard.dart';

class FlashcardsRepository {
  FlashcardsRepository(this._db);

  final AppDatabase _db;

  Future<List<FlashcardDeck>> getDecks() async {
    final db = await _db.database;
    final rows = await db.query(Tables.flashcards,
        orderBy: '${Columns.createdAt} DESC');
    return rows.map(FlashcardDeck.fromMap).toList();
  }

  Future<int> addDeck(FlashcardDeck d) async {
    final db = await _db.database;
    return db.insert(Tables.flashcards, d.toMap());
  }

  Future<void> deleteDeck(int id) async {
    final db = await _db.database;
    await db.delete(Tables.flashcards,
        where: '${Columns.id} = ?', whereArgs: [id]);
  }

  Future<List<Flashcard>> getCards(int deckId) async {
    final db = await _db.database;
    final rows = await db.query(
      'flash_cards',
      where: 'deck_id = ?',
      whereArgs: [deckId],
      orderBy: 'id ASC',
    );
    return rows.map(Flashcard.fromMap).toList();
  }

  Future<int> addCard(Flashcard c) async {
    final db = await _db.database;
    return db.insert('flash_cards', c.toMap());
  }

  Future<void> deleteCard(int id) async {
    final db = await _db.database;
    await db.delete('flash_cards',
        where: '${Columns.id} = ?', whereArgs: [id]);
  }

  Future<void> recordReview(int cardId, int quality) async {
    final db = await _db.database;
    await db.insert(Tables.flashcardReviews, {
      'card_id': cardId,
      'reviewed_at': DateTime.now().millisecondsSinceEpoch,
      'quality': quality,
    });
  }

  Future<int> countCards(int deckId) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM flash_cards WHERE deck_id = ?',
      [deckId],
    );
    return (rows.first['c'] as int?) ?? 0;
  }
}