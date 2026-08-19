import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla,AppLocalizationsCamelCase;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/constants/app_routes.dart';
import '../models/expense.dart';
import '../view_models/expenses_view_model.dart';

class ExpensesView extends ConsumerStatefulWidget {
  const ExpensesView({super.key});

  @override
  ConsumerState<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends ConsumerState<ExpensesView> {
  TransactionType _tab = TransactionType.expense;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(expensesViewModelProvider.notifier).bootstrap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(expensesViewModelProvider);
    final expenseRows =
        state.expenses.where((e) => e.type == _tab).toList();
    final isBangla = l10n.isBangla;
    final netColor = state.netThisMonth >= 0
        ? AppColors.success
        : AppColors.error;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.expenses),
        actions: [
          IconButton(
            tooltip: isBangla ? 'আয় যোগ করুন' : 'Add income',
            icon: const Icon(Icons.payments_outlined),
            onPressed: () => context.push(AppRoutes.incomeAdd),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab-expenses',
        onPressed: () =>
            context.push(_tab == TransactionType.expense
                ? AppRoutes.expenseAdd
                : AppRoutes.incomeAdd),
        child: Icon(_tab == TransactionType.expense
            ? Icons.attach_money_rounded
            : Icons.add),
      ),
      body: state.isLoading
          ? const AppLoading()
          : Column(
              children: [
                // Summary card
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('This month',
                            style: TextStyle(
                                color:
                                    ThemeColors.textSecondary(context),
                                fontSize: 12)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryCell(
                                label: isBangla ? 'খরচ' : 'Spent',
                                value: state.totalThisMonth,
                                color: AppColors.error,
                                icon: Icons.trending_down_rounded,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: ThemeColors.border(context),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            Expanded(
                              child: _SummaryCell(
                                label:
                                    isBangla ? 'আয়' : 'Earned',
                                value: state.totalIncomeThisMonth,
                                color: AppColors.success,
                                icon: Icons.trending_up_rounded,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: ThemeColors.border(context),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            Expanded(
                              child: _SummaryCell(
                                label: isBangla ? 'নিট' : 'Net',
                                value: state.netThisMonth,
                                color: netColor,
                                icon: Icons.balance_rounded,
                              ),
                            ),
                          ],
                        ),
                        if (state.categoryTotals.isNotEmpty &&
                            _tab == TransactionType.expense) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: state.categoryTotals.entries
                                .map((e) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${e.key.name} ৳${e.value.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                        if (state.incomeCategoryTotals.isNotEmpty &&
                            _tab == TransactionType.income) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: state.incomeCategoryTotals.entries
                                .map((e) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.success
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${_incomeLabel(e.key, isBangla)} ৳${e.value.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                            color: AppColors.success,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Tabs
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: SegmentedButton<TransactionType>(
                    segments: [
                      ButtonSegment(
                        value: TransactionType.expense,
                        icon: const Icon(Icons.attach_money_rounded, size: 18),
                        label: Text(l10n.quickAddExpense),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        icon: const Icon(Icons.payments_outlined, size: 18),
                        label: Text(l10n.quickAddIncome),
                      ),
                    ],
                    selected: {_tab},
                    onSelectionChanged: (s) =>
                        setState(() => _tab = s.first),
                  ),
                ),
                Expanded(
                  child: expenseRows.isEmpty
                      ? AppEmptyState(
                          title: _tab == TransactionType.expense
                              ? l10n.noExpenses
                              : (isBangla
                                  ? 'কোনো আয় নেই'
                                  : 'No income yet'),
                          message: _tab == TransactionType.expense
                              ? l10n.expensesHint
                              : (isBangla
                                  ? 'প্রথম আয় যোগ করুন'
                                  : 'Add your first income'),
                          icon: _tab == TransactionType.expense
                              ? Icons.account_balance_wallet_outlined
                              : Icons.payments_outlined,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                          itemCount: expenseRows.length,
                          itemBuilder: (_, i) {
                            final e = expenseRows[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: AppCard(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: e.type == TransactionType.income
                                            ? AppColors.success
                                                .withValues(alpha: 0.12)
                                            : AppColors.primaryLight,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        e.type == TransactionType.income
                                            ? Icons.payments_outlined
                                            : Icons.receipt_long,
                                        color:
                                            e.type == TransactionType.income
                                                ? AppColors.success
                                                : AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(e.title,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight:
                                                      FontWeight.w600)),
                                          Text(
                                              '${e.type == TransactionType.income ? _incomeLabel(e.incomeCategory ?? IncomeCategory.other, isBangla) : e.category.name} • ${du.AppDateUtils.relative(e.date)}',
                                              style: TextStyle(
                                                  color: ThemeColors
                                                      .textSecondary(
                                                          context),
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                        (e.type == TransactionType.income
                                                ? '+৳'
                                                : '৳') +
                                            e.amount.toStringAsFixed(0),
                                        style: TextStyle(
                                            color: e.type ==
                                                    TransactionType.income
                                                ? AppColors.success
                                                : null,
                                            fontWeight:
                                                FontWeight.w600)),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.delete_outline),
                                      onPressed: () async {
                                        if (e.id != null) {
                                          await ref
                                              .read(
                                                  expensesViewModelProvider
                                                      .notifier)
                                              .deleteExpense(e.id!);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  String _incomeLabel(IncomeCategory c, bool isBangla) {
    if (isBangla) {
      switch (c) {
        case IncomeCategory.allowance:
          return 'ভর্তুকি';
        case IncomeCategory.partTime:
          return 'পার্ট-টাইম';
        case IncomeCategory.fullTime:
          return 'ফুল-টাইম';
        case IncomeCategory.gift:
          return 'উপহার';
        case IncomeCategory.scholarship:
          return 'বৃত্তি';
        case IncomeCategory.other:
          return 'অন্যান্য';
      }
    }
    switch (c) {
      case IncomeCategory.allowance:
        return 'Allowance';
      case IncomeCategory.partTime:
        return 'Part-time';
      case IncomeCategory.fullTime:
        return 'Full-time';
      case IncomeCategory.gift:
        return 'Gift';
      case IncomeCategory.scholarship:
        return 'Scholarship';
      case IncomeCategory.other:
        return 'Other';
    }
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text('৳${value.toStringAsFixed(0)}',
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 16)),
        Text(label,
            style: TextStyle(
                color: ThemeColors.textSecondary(context),
                fontSize: 11)),
      ],
    );
  }
}