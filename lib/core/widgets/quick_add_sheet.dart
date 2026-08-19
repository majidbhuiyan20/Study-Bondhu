import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/assignments/views/assignment_add_view.dart';
import '../../features/exams/views/exam_add_view.dart';
import '../../features/notes/views/note_editor_view.dart';
import '../../features/subjects/views/subject_add_view.dart';
import '../constants/app_routes.dart';
import '../l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../theme/theme_colors.dart';

/// Central "+ Add" sheet referenced by every screen's FAB per spec 35.
/// Each tile navigates to the relevant add view. We use a single
/// `showModalBottomSheet` to keep context, per the spec rationale.
class QuickAddSheet extends StatelessWidget {
  const QuickAddSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ThemeColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const QuickAddSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tiles = <_QuickTile>[
      _QuickTile(
        icon: Icons.menu_book_rounded,
        label: l10n.quickAddSubject,
        onTap: () => _open(context, const SubjectAddView()),
      ),
      _QuickTile(
        icon: Icons.task_alt_rounded,
        label: l10n.quickAddTask,
        onTap: () => _open(context, const AssignmentAddView()),
      ),
      _QuickTile(
        icon: Icons.event_rounded,
        label: l10n.quickAddExam,
        onTap: () => _open(context, const ExamAddView()),
      ),
      _QuickTile(
        icon: Icons.account_tree_rounded,
        label: l10n.quickAddTopic,
        onTap: () => context.push(AppRoutes.topicAdd),
      ),
      _QuickTile(
        icon: Icons.sticky_note_2_outlined,
        label: l10n.quickAddNote,
        onTap: () => _open(context, const NoteEditorView()),
      ),
      _QuickTile(
        icon: Icons.timer_outlined,
        label: l10n.quickAddStudy,
        onTap: () => context.push(AppRoutes.studyTimer),
      ),
      _QuickTile(
        icon: Icons.how_to_reg_outlined,
        label: l10n.quickAddAttendance,
        onTap: () => context.push(AppRoutes.attendance),
      ),
      _QuickTile(
        icon: Icons.style_outlined,
        label: l10n.quickAddFlashcard,
        onTap: () => context.push(AppRoutes.flashcardDeckAdd),
      ),
      _QuickTile(
        icon: Icons.attach_money_rounded,
        label: l10n.quickAddExpense,
        onTap: () => context.push(AppRoutes.expenseAdd),
      ),
      _QuickTile(
        icon: Icons.payments_outlined,
        label: l10n.quickAddIncome,
        onTap: () => context.push(AppRoutes.incomeAdd),
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: ThemeColors.textTertiary(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                '+ ${l10n.quickAddTitle}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tiles.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (_, i) => tiles[i],
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget view) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => view));
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ThemeColors.surfaceAlt(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: Theme.of(context).colorScheme.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}