enum ExpenseCategory { books, transport, food, courses, supplies, other }

extension ExpenseCategoryX on ExpenseCategory {
  String get key => name;
  static ExpenseCategory fromKey(String k) =>
      ExpenseCategory.values.firstWhere((e) => e.name == k,
          orElse: () => ExpenseCategory.other);
}

/// Discriminates a row in the `expenses` table. `expense` rows use
/// [ExpenseCategory]; `income` rows use [IncomeCategory].
enum TransactionType { expense, income }

extension TransactionTypeX on TransactionType {
  String get code => name;
  static TransactionType fromCode(String? raw) {
    if (raw == null) return TransactionType.expense;
    return TransactionType.values.firstWhere(
      (t) => t.name == raw,
      orElse: () => TransactionType.expense,
    );
  }
}

/// Income sources — allowance, part-time job, full-time job, gift,
/// scholarship, or other. Bengali students in particular have a mix of
/// allowance and tutorial income (part-time teaching).
enum IncomeCategory { allowance, partTime, fullTime, gift, scholarship, other }

extension IncomeCategoryX on IncomeCategory {
  String get key => name;
  static IncomeCategory fromKey(String k) =>
      IncomeCategory.values.firstWhere((e) => e.name == k,
          orElse: () => IncomeCategory.other);
}

class Expense {
  final int? id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String? note;
  final TransactionType type;
  final IncomeCategory? incomeCategory;
  final DateTime createdAt;

  const Expense({
    this.id,
    required this.title,
    required this.amount,
    this.category = ExpenseCategory.other,
    required this.date,
    this.note,
    this.type = TransactionType.expense,
    this.incomeCategory,
    required this.createdAt,
  });

  /// Convenience for callers that don't care which category enum applies.
  String get categoryKey => type == TransactionType.expense
      ? category.name
      : (incomeCategory?.name ?? 'other');

  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
    TransactionType? type,
    IncomeCategory? incomeCategory,
    DateTime? createdAt,
  }) =>
      Expense(
        id: id ?? this.id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        date: date ?? this.date,
        note: note ?? this.note,
        type: type ?? this.type,
        incomeCategory: incomeCategory ?? this.incomeCategory,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'amount': amount,
        'category': categoryKey,
        'date': date.millisecondsSinceEpoch,
        'note': note,
        'type': type.code,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Expense.fromMap(Map<String, Object?> m) => Expense(
        id: m['id'] as int?,
        title: m['title'] as String,
        amount: (m['amount'] as num).toDouble(),
        type: TransactionTypeX.fromCode(m['type'] as String?),
        category: m['type'] == 'income'
            ? ExpenseCategory.other
            : ExpenseCategoryX.fromKey(m['category'] as String? ?? 'other'),
        incomeCategory: m['type'] == 'income'
            ? IncomeCategoryX.fromKey(m['category'] as String? ?? 'other')
            : null,
        date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
        note: m['note'] as String?,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );

  /// Construct an expense row.
  factory Expense.expense({
    int? id,
    required String title,
    required double amount,
    ExpenseCategory category = ExpenseCategory.other,
    required DateTime date,
    String? note,
    DateTime? createdAt,
  }) =>
      Expense(
        id: id,
        title: title,
        amount: amount,
        category: category,
        date: date,
        note: note,
        type: TransactionType.expense,
        createdAt: createdAt ?? DateTime.now(),
      );

  /// Construct an income row.
  factory Expense.income({
    int? id,
    required String title,
    required double amount,
    IncomeCategory incomeCategory = IncomeCategory.allowance,
    required DateTime date,
    String? note,
    DateTime? createdAt,
  }) =>
      Expense(
        id: id,
        title: title,
        amount: amount,
        date: date,
        note: note,
        type: TransactionType.income,
        incomeCategory: incomeCategory,
        createdAt: createdAt ?? DateTime.now(),
      );
}