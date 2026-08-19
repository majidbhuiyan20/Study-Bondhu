import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/deadline_bucket.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/deadline_bucket_chip.dart';
import '../../../core/widgets/quick_add_sheet.dart';
import '../models/assignment.dart';
import '../view_models/assignments_view_model.dart';
import '../widgets/assignment_card.dart';
import '../widgets/assignment_subtasks_sheet.dart';

class AssignmentsView extends ConsumerStatefulWidget {
  const AssignmentsView({super.key});

  @override
  ConsumerState<AssignmentsView> createState() => _AssignmentsViewState();
}

class _AssignmentsViewState extends ConsumerState<AssignmentsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(assignmentsViewModelProvider.notifier).bootstrap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(assignmentsViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.assignments)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-assignments',
        onPressed: () => QuickAddSheet.show(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addAssignment),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: _Body(state: state),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.state});
  final AssignmentsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (state.isLoading) return const AppLoading();
    if (state.assignments.isEmpty) {
      return AppEmptyState(
        title: l10n.noAssignments,
        message: l10n.assignmentsHint,
        icon: Icons.assignment_outlined,
        actionLabel: l10n.addAssignment,
        onAction: () =>
            context.push(AppRoutes.assignmentAdd),
      );
    }
    final pending = state.assignments
        .where((a) => a.status == AssignmentStatus.pending)
        .toList()
      ..sort((a, b) {
        // Items with a due date come first (soonest first); no-date items
        // go to the bottom.
        final ad = a.dueDate;
        final bd = b.dueDate;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return ad.compareTo(bd);
      });
    final completed = state.assignments
        .where((a) => a.status == AssignmentStatus.completed)
        .toList()
      ..sort((a, b) {
        final ad = a.completedAt ?? a.createdAt;
        final bd = b.completedAt ?? b.createdAt;
        return bd.compareTo(ad);
      });

    // Group pending items by deadline bucket (spec 07 §"Buckets").
    final pendingByBucket = <DeadlineBucket, List<Assignment>>{};
    for (final a in pending) {
      pendingByBucket.putIfAbsent(bucketFor(a.dueDate), () => []).add(a);
    }
    // Render buckets in the same order as the enum (overdue → none).
    final bucketOrder = <DeadlineBucket>[
      DeadlineBucket.overdue,
      DeadlineBucket.today,
      DeadlineBucket.tomorrow,
      DeadlineBucket.threeDays,
      DeadlineBucket.sevenDays,
      DeadlineBucket.later,
      DeadlineBucket.none,
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (pending.isNotEmpty) ...[
          _SectionHeader(l10n.pendingSection, count: pending.length),
          const SizedBox(height: 8),
          for (final bucket in bucketOrder)
            if ((pendingByBucket[bucket] ?? const []).isNotEmpty) ...[
              BucketSectionHeader(
                bucket: bucket,
                count: pendingByBucket[bucket]!.length,
              ),
              ...pendingByBucket[bucket]!.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AssignmentCard(
                      assignment: a,
                      onTap: () => ref
                          .read(assignmentsViewModelProvider.notifier)
                          .toggleComplete(a),
                      onLongPress: () => _showRowMenu(context, ref, a),
                    ),
                  )),
              const SizedBox(height: 12),
            ],
        ],
        if (completed.isNotEmpty) ...[
          _SectionHeader(l10n.completedSection, count: completed.length),
          const SizedBox(height: 8),
          ...completed.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AssignmentCard(
                  assignment: a,
                  onTap: () => ref
                      .read(assignmentsViewModelProvider.notifier)
                      .toggleComplete(a),
                  onLongPress: () => _showRowMenu(context, ref, a),
                ),
              )),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  void _showRowMenu(
    BuildContext context,
    WidgetRef ref,
    Assignment a,
  ) {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.checklist_rtl_outlined),
              title: Text(l10n.subtasksLabel),
              subtitle: const Text('Break down into smaller steps'),
              onTap: () {
                Navigator.pop(ctx);
                AssignmentSubtasksSheet.show(context, assignment: a);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              enabled: false,
              subtitle: const Text('Open the add form again to edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(ctx);
                if (a.id != null) {
                  ref
                      .read(assignmentsViewModelProvider.notifier)
                      .deleteAssignment(a.id!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {this.count});
  final String title;
  final int? count;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.titleMedium),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: ThemeColors.surfaceAlt(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$count',
                style: AppTextStyles.bodySmall.copyWith(
                    color: ThemeColors.textSecondary(context),
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ],
    );
  }
}
