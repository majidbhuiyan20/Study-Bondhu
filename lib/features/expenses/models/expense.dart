enum ExpenseCategory { books, transport, food, courses, supplies, other }

extension ExpenseCategoryX on ExpenseCategory {
  String get key => name;
  static ExpenseCategory fromKey(String k) =>
      ExpenseCategory.values.firstWhere((e) => e.name == k,
          orElse: () => ExpenseCategory.other);
}

class Expense {
  final int? id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  const Expense({
    this.id,
    required this.title,
    required this.amount,
    this.category = ExpenseCategory.other,
    required this.date,
    this.note,
    required this.createdAt,
  });

  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) =>
      Expense(
        id: id ?? this.id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        date: date ?? this.date,
        note: note ?? this.note,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'amount': amount,
        'category': category.name,
        'date': date.millisecondsSinceEpoch,
        'note': note,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Expense.fromMap(Map<String, Object?> m) => Expense(
        id: m['id'] as int?,
        title: m['title'] as String,
        amount: (m['amount'] as num).toDouble(),
        category: ExpenseCategoryX.fromKey(m['category'] as String? ?? 'other'),
        date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
        note: m['note'] as String?,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );
}