import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../models/subject.dart';
import '../view_models/subjects_view_model.dart';
import 'subject_color_swatch.dart';

/// Reusable bottom-sheet form for adding or editing a subject.
///
/// Spec 02 §"Add subject form" + spec 03 §"Edit subject".
class EditSubjectSheet extends ConsumerStatefulWidget {
  const EditSubjectSheet({super.key, this.existing});

  final Subject? existing;

  /// Shows the sheet. Returns `true` if the user saved, `null` on cancel.
  static Future<bool?> show(
    BuildContext context, {
    Subject? existing,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => EditSubjectSheet(existing: existing),
    );
  }

  @override
  ConsumerState<EditSubjectSheet> createState() => _EditSubjectSheetState();
}

class _EditSubjectSheetState extends ConsumerState<EditSubjectSheet> {
  late final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _code =
      TextEditingController(text: widget.existing?.code ?? '');
  late final _teacher =
      TextEditingController(text: widget.existing?.teacher ?? '');
  late final _credit = TextEditingController(
    text: widget.existing?.credit?.toString() ?? '',
  );
  late String _color = widget.existing?.color ?? '#4F46E5';
  late double _target = widget.existing?.targetAttendance ?? 75;
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
    final l10n = context.l10n;
    final notifier = ref.read(subjectsViewModelProvider.notifier);
    final creditVal = _credit.text.trim().isEmpty
        ? null
        : double.tryParse(_credit.text.trim());

    if (widget.existing == null) {
      // Add — assign to active semester
      final activeSem =
          ref.read(subjectsViewModelProvider).activeSemester?.id;
      await notifier.addSubject(Subject(
        name: _name.text.trim(),
        code: _code.text.trim().isEmpty ? null : _code.text.trim(),
        teacher:
            _teacher.text.trim().isEmpty ? null : _teacher.text.trim(),
        credit: creditVal,
        color: _color,
        targetAttendance: _target,
        semesterId: activeSem,
        createdAt: DateTime.now(),
      ));
    } else {
      final existing = widget.existing!;
      await notifier.updateSubject(existing.copyWith(
        name: _name.text.trim(),
        code: _code.text.trim().isEmpty ? null : _code.text.trim(),
        teacher:
            _teacher.text.trim().isEmpty ? null : _teacher.text.trim(),
        credit: creditVal,
        color: _color,
        targetAttendance: _target,
      ));
    }
    if (!mounted) return;
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.existing == null
            ? l10n.addSubjectTitle
            : l10n.editSubject),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ThemeColors.border(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEdit ? l10n.editSubject : l10n.addSubjectTitle,
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.subjectName,
                controller: _name,
                hint: l10n.subjectNameHint,
                validator: (v) => v == null || v.trim().isEmpty
                    ? l10n.requiredField
                    : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: l10n.courseCodeOptional,
                controller: _code,
                hint: l10n.courseCodeHint,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: l10n.teacherOptional,
                controller: _teacher,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: l10n.creditOptional,
                controller: _credit,
                keyboardType: TextInputType.number,
                hint: '3.0',
              ),
              const SizedBox(height: 18),
              Text(l10n.subjectColor,
                  style: AppTextStyles.label.copyWith(
                    color: ThemeColors.textSecondary(context),
                  )),
              const SizedBox(height: 8),
              SubjectColorSwatch(
                selected: _color,
                onChanged: (hex) => setState(() => _color = hex),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.targetAttendance,
                      style: AppTextStyles.label.copyWith(
                        color: ThemeColors.textSecondary(context),
                      ),
                    ),
                  ),
                  Text('${_target.round()}%',
                      style: AppTextStyles.titleSmall),
                ],
              ),
              Slider(
                min: 50,
                max: 100,
                divisions: 10,
                value: _target,
                label: '${_target.round()}%',
                onChanged: (v) => setState(() => _target = v),
              ),
              const SizedBox(height: 12),
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