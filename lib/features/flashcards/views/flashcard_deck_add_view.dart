import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart'
    show
        AppLocalizationsBangla,
        AppLocalizationsCamelCase,
        AppLocalizationsX;
import '../../../core/providers.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../models/flashcard.dart';
import '../view_models/flashcards_view_model.dart';

/// Full-screen flashcard deck add (spec #19). Reached from the Quick Add
/// sheet. Optionally linked to a subject via a dropdown.
class FlashcardDeckAddView extends ConsumerStatefulWidget {
  const FlashcardDeckAddView({super.key});

  @override
  ConsumerState<FlashcardDeckAddView> createState() =>
      _FlashcardDeckAddViewState();
}

class _FlashcardDeckAddViewState
    extends ConsumerState<FlashcardDeckAddView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  int? _subjectId;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final id =
        await ref.read(flashcardsViewModelProvider.notifier).addDeck(
              FlashcardDeck(
                name: _name.text.trim(),
                subjectId: _subjectId,
                createdAt: DateTime.now(),
              ),
            );
    if (mounted) {
      // Pop back to the Flashcards list (or whatever screen pushed us).
      Navigator.pop(context, id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isBangla = l10n.isBangla;
    final subjectsAsync = ref.watch(_subjectsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(isBangla ? 'নতুন ডেক' : 'New deck'),
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
                label: '${l10n.deckName} *',
                controller: _name,
                hint: isBangla
                    ? 'যেমন: অধ্যায় � এর শব্দ'
                    : 'e.g. Chapter 3 vocabulary',
                validator: (v) => v == null || v.trim().isEmpty
                    ? l10n.requiredField
                    : null,
              ),
              const SizedBox(height: 16),
              Text(l10n.subject,
                  style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.textSecondary(context))),
              const SizedBox(height: 6),
              subjectsAsync.when(
                data: (subjects) => DropdownButtonFormField<int?>(
                  initialValue: _subjectId,
                  decoration: InputDecoration(
                    hintText: isBangla ? 'বিষয় বাছাই করুন (ঐচ্ছিক)' : 'Pick subject (optional)',
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(isBangla ? 'কোনোটি নয়' : 'None'),
                    ),
                    ...subjects.map((s) => DropdownMenuItem<int?>(
                          value: s.id,
                          child: Text(s.name),
                        )),
                  ],
                  onChanged: (v) => setState(() => _subjectId = v),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
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