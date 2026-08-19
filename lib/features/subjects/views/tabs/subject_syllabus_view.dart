import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../models/syllabus_item.dart';
import '../../view_models/subjects_view_model.dart';

/// Spec 03 §"Syllabus tab" — ordered, re-orderable checklist list.
class SubjectSyllabusView extends ConsumerWidget {
  const SubjectSyllabusView({
    super.key,
    required this.subjectId,
    required this.onAdd,
  });

  final int subjectId;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(syllabusForSubjectProvider(subjectId));
    return async.when(
      loading: () => const AppLoading(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (items) => _SyllabusList(
        items: items,
        subjectId: subjectId,
        onAdd: onAdd,
      ),
    );
  }
}

class _SyllabusList extends ConsumerWidget {
  const _SyllabusList({
    required this.items,
    required this.subjectId,
    required this.onAdd,
  });

  final List<SyllabusItem> items;
  final int subjectId;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (items.isEmpty) {
      return AppEmptyState(
        title: l10n.noSyllabusYet,
        message: l10n.noSyllabusHint,
        icon: Icons.list_alt_outlined,
        actionLabel: l10n.syllabusAdd,
        onAction: onAdd,
      );
    }
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      buildDefaultDragHandles: false,
      onReorder: (oldIdx, newIdx) async {
        await ref
            .read(subjectsViewModelProvider.notifier)
            .reorderSyllabus(subjectId, oldIdx, newIdx);
        ref.invalidate(syllabusForSubjectProvider(subjectId));
      },
      itemBuilder: (context, i) {
        final s = items[i];
        return Padding(
          key: ValueKey('syllabus-${s.id}'),
          padding: const EdgeInsets.only(bottom: 8),
          child: AppCard(
            onTap: () async {
              await ref
                  .read(subjectsViewModelProvider.notifier)
                  .toggleSyllabus(s);
              ref.invalidate(syllabusForSubjectProvider(subjectId));
            },
            child: Row(
              children: [
                Icon(
                  s.isDone
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: s.isDone
                      ? AppColors.success
                      : ThemeColors.textSecondary(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.title,
                        style: TextStyle(
                          decoration: s.isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (s.description != null &&
                          s.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          s.description!,
                          style: TextStyle(
                            color: ThemeColors.textSecondary(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.syllabusRename,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => _renameSyllabus(context, ref, s),
                ),
                IconButton(
                  tooltip: l10n.syllabusDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () async {
                    await ref
                        .read(subjectsViewModelProvider.notifier)
                        .deleteSyllabus(s.id!);
                    ref.invalidate(syllabusForSubjectProvider(subjectId));
                  },
                ),
                ReorderableDragStartListener(
                  index: i,
                  child: Icon(
                    Icons.drag_handle_rounded,
                    color: ThemeColors.textTertiary(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _renameSyllabus(
      BuildContext context, WidgetRef ref, SyllabusItem s) async {
    final ctrl = TextEditingController(text: s.title);
    final newTitle = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: ctrl, autofocus: true),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(context.l10n.cancel),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () =>
                      Navigator.pop(ctx, ctrl.text.trim()),
                  child: Text(context.l10n.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (newTitle != null && newTitle.isNotEmpty) {
      await ref
          .read(subjectsViewModelProvider.notifier)
          .renameSyllabus(s, newTitle);
      ref.invalidate(syllabusForSubjectProvider(subjectId));
    }
  }
}
