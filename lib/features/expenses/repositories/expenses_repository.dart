import '../../../database/app_database.dart';
import '../../../database/database_tables.dart';
import '../models/expense.dart';

class ExpensesRepository {
  ExpensesRepository(this._db);

  final AppDatabase _db;

  Future<List<Expense>> getExpenses({DateTime? from, DateTime? to}) async {
    final db = await _db.database;
    final where = <String>[];
    final args = <Object?>[];
    if (from != null) {
      where.add('${Columns.expenseDate} >= ?');
      args.add(from.millisecondsSinceEpoch);
    }
    if (to != null) {
      where.add('${Columns.expenseDate} < ?');
      args.add(to.millisecondsSinceEpoch);
    }
    final rows = await db.query(
      Tables.expenses,
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: '${Columns.expenseDate} DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  Future<int> addExpense(Expense e) async {
    final db = await _db.database;
    return db.insert(Tables.expenses, e.toMap());
  }

  Future<void> deleteExpense(int id) async {
    final db = await _db.database;
    await db.delete(Tables.expenses,
        where: '${Columns.id} = ?', whereArgs: [id]);
  }

  Future<Map<ExpenseCategory, double>> categoryTotalsSince(DateTime from) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      'SELECT category, SUM(amount) AS total FROM ${Tables.expenses} WHERE date >= ? GROUP BY category',
      [from.millisecondsSinceEpoch],
    );
    final out = <ExpenseCategory, double>{};
    for (final r in rows) {
      out[ExpenseCategoryX.fromKey(r['category'] as String)] =
          (r['total'] as num?)?.toDouble() ?? 0;
    }
    return out;
  }
}