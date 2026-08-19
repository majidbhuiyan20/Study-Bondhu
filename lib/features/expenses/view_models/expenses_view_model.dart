import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../models/expense.dart';

class ExpensesState {
  final bool isLoading;
  final List<Expense> expenses;
  final Map<ExpenseCategory, double> categoryTotals;
  final Map<IncomeCategory, double> incomeCategoryTotals;
  final double totalIncomeThisMonth;
  const ExpensesState({
    this.isLoading = false,
    this.expenses = const [],
    this.categoryTotals = const {},
    this.incomeCategoryTotals = const {},
    this.totalIncomeThisMonth = 0,
  });
  ExpensesState copyWith({
    bool? isLoading,
    List<Expense>? expenses,
    Map<ExpenseCategory, double>? categoryTotals,
    Map<IncomeCategory, double>? incomeCategoryTotals,
    double? totalIncomeThisMonth,
  }) =>
      ExpensesState(
        isLoading: isLoading ?? this.isLoading,
        expenses: expenses ?? this.expenses,
        categoryTotals: categoryTotals ?? this.categoryTotals,
        incomeCategoryTotals:
            incomeCategoryTotals ?? this.incomeCategoryTotals,
        totalIncomeThisMonth:
            totalIncomeThisMonth ?? this.totalIncomeThisMonth,
      );

  /// Sum of all expenses logged this calendar month (only type=expense rows).
  double get totalThisMonth {
    final now = DateTime.now();
    return expenses
        .where((e) =>
            e.type == TransactionType.expense &&
            e.date.year == now.year &&
            e.date.month == now.month)
        .fold<double>(0, (acc, e) => acc + e.amount);
  }

  double get netThisMonth => totalIncomeThisMonth - totalThisMonth;
}

class ExpensesViewModel extends StateNotifier<ExpensesState> {
  ExpensesViewModel(this._ref) : super(const ExpensesState());
  final Ref _ref;

  void bootstrap() {
    Future.microtask(load);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final repo = _ref.read(expensesRepositoryProvider);
    final list = await repo.getExpenses();
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final totals = await repo.categoryTotalsSince(monthStart);
    final incomeTotals = await repo.incomeCategoryTotalsSince(monthStart);
    final incomeTotal = await repo.totalSince(
        monthStart, TransactionType.income);
    state = ExpensesState(
      isLoading: false,
      expenses: list,
      categoryTotals: totals,
      incomeCategoryTotals: incomeTotals,
      totalIncomeThisMonth: incomeTotal,
    );
  }

  Future<void> addExpense(Expense e) async {
    await _ref.read(expensesRepositoryProvider).addExpense(e);
    await load();
  }

  /// Convenience: build a typed expense row from raw fields.
  Future<void> addTypedExpense({
    required String title,
    required double amount,
    ExpenseCategory category = ExpenseCategory.other,
    required DateTime date,
    String? note,
  }) async {
    await addExpense(Expense.expense(
      title: title,
      amount: amount,
      category: category,
      date: date,
      note: note,
    ));
  }

  Future<void> addIncome({
    required String title,
    required double amount,
    IncomeCategory category = IncomeCategory.allowance,
    required DateTime date,
    String? note,
  }) async {
    await addExpense(Expense.income(
      title: title,
      amount: amount,
      incomeCategory: category,
      date: date,
      note: note,
    ));
  }

  Future<void> deleteExpense(int id) async {
    await _ref.read(expensesRepositoryProvider).deleteExpense(id);
    await load();
  }
}

final expensesViewModelProvider =
    StateNotifierProvider<ExpensesViewModel, ExpensesState>(
  (ref) => ExpensesViewModel(ref),
);