import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX, AppLocalizationsBangla, AppLocalizationsCamelCase;
import '../../../core/providers.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../models/exam.dart';
import '../view_models/exams_view_model.dart';

class ExamAddView extends ConsumerStatefulWidget {
  const ExamAddView({super.key, this.existing});
  final Exam? existing;

  @override
  ConsumerState<ExamAddView> createState() => _State();
}

class _State extends ConsumerState<ExamAddView> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _syllabus = TextEditingController();
  final _notes = TextEditingController();
  final _time = TextEditingController();
  final _location = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 7));
  ExamType _type = ExamType.midterm;
  int? _subjectId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _title.text = e.title;
      _syllabus.text = e.syllabus ?? '';
      _notes.text = e.notes ?? '';
      _time.text = e.time ?? '';
      _location.text = e.location ?? '';
      _date = e.examDate;
      _type = e.type;
      _subjectId = e.subjectId;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _syllabus.dispose();
    _notes.dispose();
    _time.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      initialDate: _date,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    if (widget.existing != null) {
      await ref.read(examsViewModelProvider.notifier).updateExam(
            widget.existing!.copyWith(
              subjectId: _subjectId,
              title: _title.text.trim(),
              examDate: _date,
              type: _type,
              syllabus: _syllabus.text.trim().isEmpty
                  ? null
                  : _syllabus.text.trim(),
              notes: _notes.text.trim().isEmpty
                  ? null
                  : _notes.text.trim(),
              time: _time.text.trim().isEmpty
                  ? null
                  : _time.text.trim(),
              location: _location.text.trim().isEmpty
                  ? null
                  : _location.text.trim(),
            ),
          );
    } else {
      await ref.read(examsViewModelProvider.notifier).addExam(
            Exam(
              subjectId: _subjectId,
              title: _title.text.trim(),
              examDate: _date,
              type: _type,
              syllabus: _syllabus.text.trim().isEmpty
                  ? null
                  : _syllabus.text.trim(),
              notes: _notes.text.trim().isEmpty
                  ? null
                  : _notes.text.trim(),
              time: _time.text.trim().isEmpty
                  ? null
                  : _time.text.trim(),
              location: _location.text.trim().isEmpty
                  ? null
                  : _location.text.trim(),
              createdAt: DateTime.now(),
            ),
          );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subjectsAsync = ref.watch(_subjectsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null
            ? l10n.examAddTitle
            : (l10n.isBangla ? 'পরীক্ষা সম্পাদনা' : 'Edit Exam')),
      ),
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
                validator: (v) => v == null || v.trim().isEmpty
                    ? l10n.requiredField
                    : null,
              ),
              const SizedBox(height: 16),
              Text('Type',
                  style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.textSecondary(context))),
              const SizedBox(height: 6),
              SegmentedButton<ExamType>(
                segments: const [
                  ButtonSegment(
                      value: ExamType.midterm, label: Text('Mid')),
                  ButtonSegment(
                      value: ExamType.finalExam, label: Text('Final')),
                  ButtonSegment(
                      value: ExamType.quiz, label: Text('Quiz')),
                  ButtonSegment(
                      value: ExamType.other, label: Text('Other')),
                ],
                selected: {_type},
                onSelectionChanged: (s) =>
                    setState(() => _type = s.first),
              ),
              const SizedBox(height: 16),
              subjectsAsync.when(
                data: (subjects) => DropdownButtonFormField<int?>(
                  initialValue: _subjectId,
                  decoration:
                      const InputDecoration(hintText: 'Subject'),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('None')),
                    ...subjects.map((s) => DropdownMenuItem(
                        value: s.id, child: Text(s.name))),
                  ],
                  onChanged: (v) => setState(() => _subjectId = v),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: Text(
                    '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.examTime,
                controller: _time,
                hint: '09:00 – 11:00',
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.examLocation,
                controller: _location,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Syllabus / Topics (optional)',
                controller: _syllabus,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Notes (optional)',
                controller: _notes,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Save exam',
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