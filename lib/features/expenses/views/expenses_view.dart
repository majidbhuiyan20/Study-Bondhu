import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/quick_add_sheet.dart';
import '../view_models/expenses_view_model.dart';

class ExpensesView extends ConsumerStatefulWidget {
  const ExpensesView({super.key});

  @override
  ConsumerState<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends ConsumerState<ExpensesView> {
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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.expenses)),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab-expenses',
        onPressed: () => QuickAddSheet.show(context),
        child: const Icon(Icons.add),
      ),
      body: state.isLoading
          ? const AppLoading()
          : state.expenses.isEmpty
              ? AppEmptyState(
                  title: l10n.noExpenses,
                  message: l10n.expensesHint,
                  icon: Icons.account_balance_wallet_outlined,
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('This month',
                              style: TextStyle(
                                  color: ThemeColors.textSecondary(context),
                                  fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('৳ ${state.totalThisMonth.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700)),
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
                                            fontWeight:
                                                FontWeight.w600),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...state.expenses.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                      Icons.receipt_long,
                                      color: AppColors.primary),
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
                                          '${e.category.name} • ${du.AppDateUtils.relative(e.date)}',
                                          style: TextStyle(
                                              color: ThemeColors
                                                  .textSecondary(context),
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Text('৳${e.amount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
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
                        )),
                    const SizedBox(height: 80),
                  ],
                ),
    );
  }
}
