import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../models/expense.dart';

class ExpensesState {
  final bool isLoading;
  final List<Expense> expenses;
  final Map<ExpenseCategory, double> categoryTotals;
  const ExpensesState({
    this.isLoading = false,
    this.expenses = const [],
    this.categoryTotals = const {},
  });
  ExpensesState copyWith({
    bool? isLoading,
    List<Expense>? expenses,
    Map<ExpenseCategory, double>? categoryTotals,
  }) =>
      ExpensesState(
        isLoading: isLoading ?? this.isLoading,
        expenses: expenses ?? this.expenses,
        categoryTotals: categoryTotals ?? this.categoryTotals,
      );

  double get totalThisMonth {
    final now = DateTime.now();
    return expenses
        .where((e) =>
            e.date.year == now.year && e.date.month == now.month)
        .fold<double>(0, (acc, e) => acc + e.amount);
  }
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
    state = ExpensesState(
      isLoading: false,
      expenses: list,
      categoryTotals: totals,
    );
  }

  Future<void> addExpense(Expense e) async {
    await _ref.read(expensesRepositoryProvider).addExpense(e);
    await load();
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