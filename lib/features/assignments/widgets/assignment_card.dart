import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart'
    show
        AppLocalizations,
        AppLocalizationsCamelCase,
        AppLocalizationsX;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/utils/deadline_bucket.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/deadline_bucket_chip.dart';
import '../models/assignment.dart';
import '../view_models/assignments_view_model.dart';

class AssignmentCard extends ConsumerWidget {
  const AssignmentCard({
    super.key,
    required this.assignment,
    this.onTap,
    this.onLongPress,
  });

  final Assignment assignment;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  Color get _priorityColor {
    switch (assignment.priority) {
      case AssignmentPriority.high:
        return AppColors.error;
      case AssignmentPriority.medium:
        return AppColors.warning;
      case AssignmentPriority.low:
        return AppColors.info;
    }
  }

  Color _bucketColor(BuildContext context) {
    final bucket = bucketFor(assignment.dueDate);
    final base = Color(bucket.hex);
    if (bucket == DeadlineBucket.overdue ||
        bucket == DeadlineBucket.today ||
        bucket == DeadlineBucket.tomorrow) {
      return base;
    }
    if (bucket == DeadlineBucket.none) {
      return Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkTextSecondary
          : AppColors.textSecondary;
    }
    return base;
  }

  String _priorityLabel(AppLocalizations l10n) {
    switch (assignment.priority) {
      case AssignmentPriority.high:
        return l10n.priorityHigh;
      case AssignmentPriority.medium:
        return l10n.priorityMedium;
      case AssignmentPriority.low:
        return l10n.priorityLow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final dueStr = assignment.dueDate == null
        ? l10n.noDatesSet
        : du.AppDateUtils.relative(assignment.dueDate!);
    final completed = assignment.status == AssignmentStatus.completed;
    final progressAsync = ref.watch(subtaskProgressProvider);
    final progress = progressAsync.maybeWhen(
      data: (m) => assignment.id == null ? 0.0 : (m[assignment.id] ?? 0.0),
      orElse: () => 0.0,
    );
    return AppCard(
      onTap: onTap,
      onLongPress: onLongPress,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Spec 06 §"Subtask progress shows as a thin bar above the title"
          if (progress > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: ThemeColors.border(context),
                  valueColor: AlwaysStoppedAnimation(
                    completed ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 4,
                height: 38,
                decoration: BoxDecoration(
                  color: _priorityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        decoration: completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: completed
                            ? (Theme.of(context).brightness ==
                                    Brightness.dark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _priorityColor.withValues(
                                alpha: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? 0.22
                                    : 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _priorityLabel(l10n),
                            style: TextStyle(
                              color: _priorityColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dueStr,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _bucketColor(context),
                            fontWeight: (bucketFor(assignment.dueDate) ==
                                        DeadlineBucket.today ||
                                    bucketFor(assignment.dueDate) ==
                                        DeadlineBucket.tomorrow ||
                                    bucketFor(assignment.dueDate) ==
                                        DeadlineBucket.overdue)
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    if (!completed && assignment.dueDate != null) ...[
                      const SizedBox(height: 6),
                      DeadlineBucketChip(date: assignment.dueDate),
                    ],
                  ],
                ),
              ),
              Icon(
                completed
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: completed
                    ? AppColors.success
                    : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary),
                size: 22,
              ),
            ],
          ),
        ],
      ),
    );
  }
}