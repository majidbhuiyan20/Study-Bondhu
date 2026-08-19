import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla,AppLocalizationsCamelCase;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../models/assignment.dart';
import '../models/assignment_subtask.dart';
import '../view_models/assignments_view_model.dart';

/// Spec 06 §"Subtasks" — bottom sheet that lists existing subtasks for an
/// assignment, lets the user add new ones, and toggle them on/off. The
/// assignment's overall progress in the [AssignmentCard] thin bar is driven
/// by the ratio of done/total subtasks.
class AssignmentSubtasksSheet extends ConsumerStatefulWidget {
  const AssignmentSubtasksSheet({super.key, required this.assignment});
  final Assignment assignment;

  static Future<void> show(
    BuildContext context, {
    required Assignment assignment,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          AssignmentSubtasksSheet(assignment: assignment),
    );
  }

  @override
  ConsumerState<AssignmentSubtasksSheet> createState() =>
      _AssignmentSubtasksSheetState();
}

class _AssignmentSubtasksSheetState
    extends ConsumerState<AssignmentSubtasksSheet> {
  final _ctrl = TextEditingController();
  bool _adding = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final title = _ctrl.text.trim();
    if (title.isEmpty) return;
    final assignmentId = widget.assignment.id;
    if (assignmentId == null) return;
    setState(() => _adding = true);
    await ref.read(assignmentsViewModelProvider.notifier).addSubtask(
          AssignmentSubtask(
            assignmentId: assignmentId,
            title: title,
          ),
        );
    if (!mounted) return;
    _ctrl.clear();
    setState(() => _adding = false);
  }

  Future<void> _toggle(AssignmentSubtask s) async {
    await ref
        .read(assignmentsViewModelProvider.notifier)
        .toggleSubtask(s);
  }

  Future<void> _delete(int subtaskId) async {
    final id = widget.assignment.id;
    if (id == null) return;
    await ref
        .read(assignmentsViewModelProvider.notifier)
        .deleteSubtask(id, subtaskId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final assignmentId = widget.assignment.id;
    return SafeArea(
      child: Padding(
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
              '${l10n.subtasksLabel} — ${widget.assignment.title}',
              style: AppTextStyles.titleLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.subtaskHint,
              style: AppTextStyles.bodySmall.copyWith(
                color: ThemeColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 14),
            if (assignmentId == null)
              Text(
                'Save the assignment first.',
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              )
            else
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    final async = ref.watch(subtasksProvider(assignmentId));
                    return async.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) =>
                          Center(child: Text('Error: $e')),
                      data: (items) {
                        if (items.isEmpty) {
                          return AppEmptyState(
                            title: l10n.noSubtasks,
                            message: l10n.subtaskHint,
                            icon: Icons.checklist_rtl_outlined,
                          );
                        }
                        final done =
                            items.where((s) => s.isDone).length;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.isBangla
                                  ? '$done/${items.length} সম্পন্ন'
                                  : '$done of ${items.length} done',
                              style: AppTextStyles.label.copyWith(
                                color: ThemeColors.textSecondary(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.separated(
                                itemCount: items.length,
                                separatorBuilder: (_, i) =>
                                    const SizedBox(height: 4),
                                itemBuilder: (_, i) {
                                  final s = items[i];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: ThemeColors.surfaceAlt(
                                          context),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: s.isDone,
                                          onChanged: (_) => _toggle(s),
                                        ),
                                        Expanded(
                                          child: Text(
                                            s.title,
                                            style: TextStyle(
                                              decoration: s.isDone
                                                  ? TextDecoration
                                                      .lineThrough
                                                  : null,
                                              color: s.isDone
                                                  ? ThemeColors
                                                      .textSecondary(
                                                          context)
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.close_rounded),
                                          onPressed: () =>
                                              _delete(s.id!),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: InputDecoration(
                      hintText: l10n.addSubtask,
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _adding ? null : _add,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
