import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart'
    show
        AppLocalizationsBangla,
        AppLocalizationsCamelCase,
        AppLocalizationsX;
import '../../../core/theme/theme_colors.dart';
import '../models/topic.dart';
import '../view_models/subjects_view_model.dart';

/// Full-screen topic add. Used by the home + Add sheet when no subject
/// context is available — the user picks a subject here, names the topic,
/// and sets the initial learning status.
class TopicAddView extends ConsumerStatefulWidget {
  const TopicAddView({super.key, this.initialSubjectId});
  final int? initialSubjectId;

  @override
  ConsumerState<TopicAddView> createState() => _TopicAddViewState();
}

class _TopicAddViewState extends ConsumerState<TopicAddView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  int? _subjectId;
  TopicStatus _status = TopicStatus.notStarted;

  @override
  void initState() {
    super.initState();
    _subjectId = widget.initialSubjectId;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (!_formKey.currentState!.validate()) return;
    if (_subjectId == null) return;
    await ref.read(subjectsViewModelProvider.notifier).addTopic(Topic(
          name: name,
          subjectId: _subjectId!,
          status: _status,
          confidence: switch (_status) {
            TopicStatus.mastered => 5,
            TopicStatus.learning => 3,
            TopicStatus.weak => 1,
            TopicStatus.notStarted => 1,
          },
          createdAt: DateTime.now(),
        ));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isBangla = l10n.isBangla;
    final subjects = ref.watch(subjectsViewModelProvider).subjects;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addTopicCta)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<int>(
                initialValue: _subjectId,
                decoration: InputDecoration(
                  labelText:
                      '${l10n.isBangla ? 'বিষয়' : 'Subject'} *',
                ),
                items: subjects
                    .map((s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(s.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _subjectId = v),
                validator: (v) =>
                    v == null ? l10n.noSubjects : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: '${l10n.revisionTopic} *',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.onboardingSubjectNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                l10n.isBangla ? 'শুরুর অবস্থা' : 'Initial status',
                style: TextStyle(
                  color: ThemeColors.textSecondary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TopicStatus.values.map((s) {
                  final selected = _status == s;
                  return ChoiceChip(
                    label: Text(isBangla ? s.bn : s.en),
                    selected: selected,
                    onSelected: (_) => setState(() => _status = s),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_rounded),
                label: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}