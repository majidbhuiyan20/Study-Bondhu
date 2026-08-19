# 20 — Student Expenses

Optional / secondary. Tracks where the student's money goes.

## Categories

```dart
enum ExpenseCategory {
  food,
  transport,
  books,
  printing,
  mobile,
  academicFee,
  other,
}
```

## Model

```dart
class Expense {
  final int? id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final DateTime createdAt;
}
```

## UI

- This month total (big number)
- Category breakdown chips
- List of expenses, newest first
- FAB → quick add sheet

## Files

```
lib/features/expenses/
├── models/expense.dart
├── repositories/expenses_repository.dart
├── view_models/expenses_view_model.dart
└── views/expenses_view.dart
```

## Scope

We do **not** try to compete with finance apps. No budgets, no charts
beyond the month total, no bank sync. Just enough to track student spend.