import 'package:flutter/material.dart';

import '../../../core/l10n.dart' show AppLocalizationsX, AppLocalizationsCamelCase;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';

/// Row of 4 small KPI chips shown under the greeting on home.
/// Today study minutes · assignments due today · weak topics · streak days
class QuickStatsRow extends StatelessWidget {
  const QuickStatsRow({
    super.key,
    required this.minutesToday,
    required this.assignmentsDue,
    required this.weakTopicCount,
    required this.streakDays,
  });

  final int minutesToday;
  final int assignmentsDue;
  final int weakTopicCount;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.timer_outlined,
            label: l10n.todaysStudy,
            value: '${minutesToday}m',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            icon: Icons.task_alt_rounded,
            label: l10n.todayTasks,
            value: '$assignmentsDue',
            color: assignmentsDue > 0 ? AppColors.warning : AppColors.info,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            icon: Icons.priority_high_rounded,
            label: l10n.weakTopics,
            value: '$weakTopicCount',
            color: weakTopicCount > 0 ? AppColors.error : AppColors.info,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            icon: Icons.local_fire_department_rounded,
            label: l10n.streak,
            value: '$streakDays',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: ThemeColors.border(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700)),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: ThemeColors.textSecondary(context)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}