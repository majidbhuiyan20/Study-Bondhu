import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart'
    show
        AppLocalizationsBangla,
        AppLocalizationsCamelCase,
        AppLocalizationsX;
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../models/expense.dart';
import '../view_models/expenses_view_model.dart';

/// Full-screen income add (spec #20 income side). Reached from the Quick
/// Add sheet via the Income tile.
class IncomeAddView extends ConsumerStatefulWidget {
  const IncomeAddView({super.key});

  @override
  ConsumerState<IncomeAddView> createState() => _IncomeAddViewState();
}

class _IncomeAddViewState extends ConsumerState<IncomeAddView> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  IncomeCategory _category = IncomeCategory.allowance;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDate: _date,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final amount = double.tryParse(_amount.text.trim());
    if (amount == null) {
      setState(() => _saving = false);
      return;
    }
    await ref.read(expensesViewModelProvider.notifier).addIncome(
          title: _title.text.trim(),
          amount: amount,
          category: _category,
          date: _date,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isBangla = l10n.isBangla;
    return Scaffold(
      appBar: AppBar(
        title: Text(isBangla ? 'নতুন আয়' : 'New income'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: '${l10n.title} *',
                controller: _title,
                hint: isBangla
                    ? 'যেমন: মাসিক ভর্তুকি'
                    : 'e.g. Monthly allowance',
                validator: (v) => v == null || v.trim().isEmpty
                    ? l10n.requiredField
                    : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: '${l10n.expenseAmount} *',
                controller: _amount,
                hint: '৳ 0',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.requiredField;
                  }
                  final n = double.tryParse(v.trim());
                  if (n == null || n < 0) {
                    return isBangla
                        ? 'সঠিক পরিমাণ দিন'
                        : 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text('Income category',
                  style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.textSecondary(context))),
              const SizedBox(height: 6),
              DropdownButtonFormField<IncomeCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  hintText: 'Select category',
                ),
                items: IncomeCategory.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(_categoryLabel(c, isBangla)),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _category = v);
                },
              ),
              const SizedBox(height: 16),
              Text(l10n.dueDate,
                  style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.textSecondary(context))),
              const SizedBox(height: 6),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: Text(
                  '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: '${l10n.expenseNote} (optional)',
                controller: _note,
                maxLines: 3,
                minLines: 2,
              ),
              const SizedBox(height: 32),
              AppButton(
                label: l10n.save,
                onPressed: _saving ? null : _save,
                isLoading: _saving,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryLabel(IncomeCategory c, bool isBangla) {
    if (!isBangla) {
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
}