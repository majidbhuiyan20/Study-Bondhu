import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla,AppLocalizationsCamelCase;
import '../../../../core/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../notes/models/note.dart';
import '../../models/topic.dart';
import '../../view_models/subjects_view_model.dart';

/// Status dot color picker shared by topic status rows (spec 05).
Color topicStatusColor(TopicStatus s) {
  switch (s) {
    case TopicStatus.notStarted:
      return AppColors.textTertiary;
    case TopicStatus.learning:
      return _warningColor;
    case TopicStatus.weak:
      return _errorColor;
    case TopicStatus.mastered:
      return _successColor;
  }
}

const Color _warningColor = Color(0xFFEAB308);
const Color _errorColor = Color(0xFFDC2626);
const Color _successColor = Color(0xFF16A34A);

class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.status});
  final TopicStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: topicStatusColor(status),
        shape: BoxShape.circle,
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});
  final TopicStatus status;

  @override
  Widget build(BuildContext context) {
    final color = topicStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        switch (status) {
          TopicStatus.notStarted => '⚪',
          TopicStatus.learning => '🟡',
          TopicStatus.weak => '🔴',
          TopicStatus.mastered => '🟢',
        },
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

/// Compact "Add / Edit topic" bottom sheet (spec 05).
class AddTopicSheet extends ConsumerStatefulWidget {
  const AddTopicSheet({super.key, required this.subjectId, this.existing});

  final int subjectId;
  final Topic? existing;

  static Future<void> show(
    BuildContext context, {
    required int subjectId,
    Topic? existing,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddTopicSheet(subjectId: subjectId, existing: existing),
    );
  }

  @override
  ConsumerState<AddTopicSheet> createState() => _AddTopicSheetState();
}

class _AddTopicSheetState extends ConsumerState<AddTopicSheet> {
  late final _nameCtl =
      TextEditingController(text: widget.existing?.name ?? '');
  late TopicStatus _status =
      widget.existing?.status ?? TopicStatus.notStarted;

  @override
  void dispose() {
    _nameCtl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtl.text.trim();
    if (name.isEmpty) return;
    final vm = ref.read(subjectsViewModelProvider.notifier);
    if (widget.existing == null) {
      await vm.addTopic(Topic(
        name: name,
        subjectId: widget.subjectId,
        status: _status,
        confidence: switch (_status) {
          TopicStatus.mastered => 5,
          TopicStatus.weak => 1,
          TopicStatus.learning => 3,
          _ => 3,
        },
        createdAt: DateTime.now(),
      ));
    } else {
      await vm.updateTopic(widget.existing!.copyWith(
        name: name,
        status: _status,
        confidence: switch (_status) {
          TopicStatus.mastered => 5,
          TopicStatus.weak => 1,
          _ => widget.existing!.confidence,
        },
        isCompleted: _status == TopicStatus.mastered,
      ));
    }
    ref.invalidate(topicsForSubjectProvider(widget.subjectId));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
          Text(
            widget.existing == null ? l10n.addTopic : l10n.editTopic,
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtl,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.subjectName),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.topicStatusLabel,
            style: AppTextStyles.label.copyWith(
              color: ThemeColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TopicStatus.values.map((s) {
              final selected = _status == s;
              final color = topicStatusColor(s);
              return GestureDetector(
                onTap: () => setState(() => _status = s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withValues(alpha: 0.18)
                        : ThemeColors.surfaceAlt(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? color : ThemeColors.border(context),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.isBangla ? s.bn : s.en,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              const Spacer(),
              if (widget.existing != null) ...[
                TextButton(
                  onPressed: () async {
                    await ref
                        .read(subjectsViewModelProvider.notifier)
                        .deleteTopic(widget.existing!.id!);
                    if (!mounted) return;
                    ref.invalidate(
                        topicsForSubjectProvider(widget.subjectId));
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  child: Text(
                    l10n.delete,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(width: 8),
              ],
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

/// Note create / edit sheet (spec 18). Same widget used in Notes screen
/// and inside the subject's Notes tab.
class AddNoteSheet extends ConsumerStatefulWidget {
  const AddNoteSheet({super.key, required this.subjectId, this.existing});

  final int subjectId;
  final Note? existing;

  static Future<void> show(
    BuildContext context, {
    required int subjectId,
    Note? existing,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddNoteSheet(subjectId: subjectId, existing: existing),
    );
  }

  @override
  ConsumerState<AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends ConsumerState<AddNoteSheet> {
  late final _titleCtl =
      TextEditingController(text: widget.existing?.title ?? '');
  late final _bodyCtl =
      TextEditingController(text: widget.existing?.body ?? '');

  @override
  void dispose() {
    _titleCtl.dispose();
    _bodyCtl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtl.text.trim();
    if (title.isEmpty) return;
    final repo = ref.read(notesRepositoryProvider);
    if (widget.existing == null) {
      await repo.addNote(Note(
        subjectId: widget.subjectId,
        title: title,
        body: _bodyCtl.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    } else {
      await repo.updateNote(widget.existing!.copyWith(
        title: title,
        body: _bodyCtl.text,
        updatedAt: DateTime.now(),
      ));
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (widget.existing == null) return;
    await ref
        .read(notesRepositoryProvider)
        .deleteNote(widget.existing!.id!);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
          Text(
            widget.existing == null ? l10n.addNewNote : l10n.edit,
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtl,
            autofocus: widget.existing == null,
            decoration: InputDecoration(labelText: l10n.noteTitleHint),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyCtl,
            maxLines: 8,
            minLines: 4,
            decoration: InputDecoration(
              labelText: l10n.noteBodyHint,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (widget.existing != null)
                TextButton(
                  onPressed: _delete,
                  child: Text(
                    l10n.delete,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: 8),
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

/// Reusable stat tile (Total hours / Sessions / Avg session / Most studied).
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.label.copyWith(
                    color: ThemeColors.textSecondary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Cascade-count row used inside the delete-subject confirmation dialog.
class CascadeRow extends StatelessWidget {
  const CascadeRow({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: ThemeColors.textSecondary(context)),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            '$count',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// End of subject_detail_widgets.dart