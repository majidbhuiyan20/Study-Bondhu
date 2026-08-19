import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../models/subject.dart';
import '../view_models/subjects_view_model.dart';
import '../widgets/subject_color_swatch.dart';

class SubjectAddView extends ConsumerStatefulWidget {
  const SubjectAddView({super.key});

  @override
  ConsumerState<SubjectAddView> createState() => _SubjectAddViewState();
}

class _SubjectAddViewState extends ConsumerState<SubjectAddView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _teacher = TextEditingController();
  final _credit = TextEditingController();
  String _color = '#4F46E5';
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _teacher.dispose();
    _credit.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final active =
        ref.read(subjectsViewModelProvider).activeSemester?.id;
    await ref.read(subjectsViewModelProvider.notifier).addSubject(
          Subject(
            name: _name.text.trim(),
            code: _code.text.trim().isEmpty ? null : _code.text.trim(),
            teacher:
                _teacher.text.trim().isEmpty ? null : _teacher.text.trim(),
            credit: _credit.text.trim().isEmpty
                ? null
                : double.tryParse(_credit.text.trim()),
            color: _color,
            semesterId: active,
            createdAt: DateTime.now(),
          ),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addSubjectTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: l10n.subjectName,
                controller: _name,
                hint: l10n.subjectNameHint,
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? l10n.requiredField
                        : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.courseCodeOptional,
                controller: _code,
                hint: l10n.courseCodeHint,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.teacherOptional,
                controller: _teacher,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.creditOptional,
                controller: _credit,
                keyboardType: TextInputType.number,
                hint: '3.0',
              ),
              const SizedBox(height: 16),
              Text(l10n.colorLabel,
                  style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.textSecondary(context))),
              const SizedBox(height: 8),
              SubjectColorSwatch(
                selected: _color,
                onChanged: (hex) => setState(() => _color = hex),
              ),
              const SizedBox(height: 32),
              AppButton(
                label: l10n.saveSubject,
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