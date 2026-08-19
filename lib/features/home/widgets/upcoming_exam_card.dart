import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/widgets/app_card.dart';
import '../../exams/models/exam.dart';

class UpcomingExamCard extends StatelessWidget {
  const UpcomingExamCard({super.key, required this.exams});
  final List<Exam> exams;

  @override
  Widget build(BuildContext context) {
    if (exams.isEmpty) return const SizedBox.shrink();
    final next = exams.first;
    final days = du.AppDateUtils.daysUntil(next.examDate);
    final isUrgent = days <= 3 && days >= 0;
    final monthAbr = du.AppDateUtils.formatMonthDay(next.examDate)
        .split(' ')
        .first;
    return AppCard(
      onTap: () => context.push(AppRoutes.exams),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _chipBg(context, isUrgent),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  monthAbr,
                  style: TextStyle(
                    color: isUrgent ? AppColors.accent : AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${next.examDate.day}',
                  style: TextStyle(
                    color: isUrgent ? AppColors.accent : AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  next.title,
                  style: AppTextStyles.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  days == 0
                      ? 'Today · ${next.type.name}'
                      : days > 0
                          ? 'In $days days · ${next.type.name}'
                          : next.type.name,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isUrgent
                        ? AppColors.accent
                        : ThemeColors.textSecondary(context),
                    fontWeight: isUrgent ? FontWeight.w700 : null,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: ThemeColors.textSecondary(context)),
        ],
      ),
    );
  }

  Color _chipBg(BuildContext context, bool urgent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (urgent) {
      return isDark
          ? AppColors.accent.withValues(alpha: 0.18)
          : AppColors.accentLight;
    }
    return isDark
        ? AppColors.primary.withValues(alpha: 0.18)
        : AppColors.primaryLight;
  }
}
