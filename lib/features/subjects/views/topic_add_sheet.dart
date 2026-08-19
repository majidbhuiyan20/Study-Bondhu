import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla,AppLocalizationsCamelCase;
import '../models/topic.dart';
import '../view_models/subjects_view_model.dart';

/// Reusable bottom sheet for adding a topic to a subject.
/// Used both inside the Subject Details Topics tab and from the
/// Quick Add sheet (35).
class TopicAddSheet extends ConsumerStatefulWidget {
  const TopicAddSheet({super.key, required this.subjectId});
  final int subjectId;

  static Future<void> show(BuildContext context, {int? subjectId}) {
    if (subjectId == null) {
      // No subject specified — caller must pick one. We surface a
      // hint so we don't silently add a topic without context.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.noSubjects),
      ));
      return Future.value();
    }
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TopicAddSheet(subjectId: subjectId),
    );
  }

  @override
  ConsumerState<TopicAddSheet> createState() => _TopicAddSheetState();
}

class _TopicAddSheetState extends ConsumerState<TopicAddSheet> {
  final _name = TextEditingController();
  TopicStatus _status = TopicStatus.notStarted;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    await ref.read(subjectsViewModelProvider.notifier).addTopic(Topic(
          name: name,
          subjectId: widget.subjectId,
          status: _status,
          confidence: switch (_status) {
            TopicStatus.mastered => 5,
            TopicStatus.learning => 3,
            TopicStatus.weak => 1,
            TopicStatus.notStarted => 1,
          },
          createdAt: DateTime.now(),
        ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isBangla = l10n.isBangla;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.addTopicCta,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            decoration: InputDecoration(hintText: l10n.revisionTopic),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _save,
                child: Text(l10n.save),
              ),
            ],
          ),
        ],
      ),
    );
  }
}