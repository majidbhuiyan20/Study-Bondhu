import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla,AppLocalizationsCamelCase;
import '../../../core/providers.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../subjects/view_models/subjects_view_model.dart';
import '../models/assignment.dart';
import '../view_models/assignments_view_model.dart';

class AssignmentAddView extends ConsumerStatefulWidget {
  const AssignmentAddView({super.key});

  @override
  ConsumerState<AssignmentAddView> createState() => _State();
}

class _State extends ConsumerState<AssignmentAddView> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _estimate = TextEditingController();
  DateTime? _due;
  AssignmentPriority _priority = AssignmentPriority.medium;
  AssignmentType _type = AssignmentType.assignment;
  int? _subjectId;
  int? _topicId;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _estimate.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365 * 2)),
      initialDate: _due ?? now.add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _due = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final estimateMin = int.tryParse(_estimate.text.trim());
    await ref.read(assignmentsViewModelProvider.notifier).addAssignment(
          Assignment(
            subjectId: _subjectId,
            topicId: _topicId,
            title: _title.text.trim(),
            description: _desc.text.trim().isEmpty
                ? null
                : _desc.text.trim(),
            dueDate: _due,
            priority: _priority,
            type: _type,
            estimatedMinutes: estimateMin,
            createdAt: DateTime.now(),
          ),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subjectsAsync = ref.watch(_subjectsProvider);
    final topicsAsync = _subjectId == null
        ? const AsyncValue.data(<dynamic>[])
        : ref.watch(topicsForSubjectProvider(_subjectId!));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.assignmentAddTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: l10n.title,
                controller: _title,
                hint: 'e.g. Chapter 3 exercise',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? l10n.requiredField : null,
              ),
              const SizedBox(height: 16),
              // Spec 06 §"Add form" — Type picker
              Text('Type',
                  style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.textSecondary(context))),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AssignmentType.values.map((t) {
                  final selected = _type == t;
                  return ChoiceChip(
                    label: Text(l10n.isBangla ? t.bn : t.en),
                    selected: selected,
                    onSelected: (_) => setState(() => _type = t),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Description (optional)',
                controller: _desc,
                maxLines: 4,
                minLines: 2,
              ),
              const SizedBox(height: 16),
              Text(l10n.subject,
                  style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.textSecondary(context))),
              const SizedBox(height: 6),
              subjectsAsync.when(
                data: (subjects) => DropdownButtonFormField<int?>(
                  value: _subjectId,
                  decoration:
                      const InputDecoration(hintText: 'Select subject'),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('None')),
                    ...subjects.map((s) => DropdownMenuItem(
                        value: s.id, child: Text(s.name))),
                  ],
                  onChanged: (v) => setState(() {
                    _subjectId = v;
                    _topicId = null;
                  }),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
              if (_subjectId != null) ...[
                const SizedBox(height: 12),
                topicsAsync.when(
                  data: (topics) => DropdownButtonFormField<int?>(
                    value: _topicId,
                    decoration:
                        const InputDecoration(hintText: 'Select topic'),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('None')),
                      ...topics.map((t) => DropdownMenuItem(
                          value: t.id as int?,
                          child: Text(t.name))),
                    ],
                    onChanged: (v) => setState(() => _topicId = v),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                ),
              ],
              const SizedBox(height: 16),
              Text(l10n.priority,
                  style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.textSecondary(context))),
              const SizedBox(height: 6),
              SegmentedButton<AssignmentPriority>(
                segments: [
                  ButtonSegment(
                      value: AssignmentPriority.low,
                      label: Text(l10n.priorityLow)),
                  ButtonSegment(
                      value: AssignmentPriority.medium,
                      label: Text(l10n.priorityMedium)),
                  ButtonSegment(
                      value: AssignmentPriority.high,
                      label: Text(l10n.priorityHigh)),
                ],
                selected: {_priority},
                onSelectionChanged: (s) =>
                    setState(() => _priority = s.first),
              ),
              const SizedBox(height: 16),
              // Spec 06 §"Estimated minutes"
              AppTextField(
                label: 'Estimated minutes (optional)',
                controller: _estimate,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: Text(_due == null
                    ? 'Pick due date'
                    : '${_due!.year}-${_due!.month.toString().padLeft(2, '0')}-${_due!.day.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickDue,
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
}

final _subjectsProvider = FutureProvider((ref) async {
  return ref.watch(subjectsRepositoryProvider).getSubjects();
});