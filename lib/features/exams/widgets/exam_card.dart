import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/deadline_bucket_chip.dart';
import '../models/exam.dart';

class ExamCard extends StatelessWidget {
  const ExamCard({super.key, required this.exam, this.onTap});
  final Exam exam;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final days = du.AppDateUtils.daysUntil(exam.examDate);
    final isUrgent = days <= 3 && days >= 0;
    final monthAbr = du.AppDateUtils.formatMonthDay(exam.examDate)
        .split(' ')
        .first;
    final daysLabel = days == 0
        ? 'Today'
        : days > 0
            ? 'In $days days'
            : '${days.abs()} days ago';
    final l10n = context.l10n;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap ??
          () => context.push(
                AppRoutes.examPreparation.replaceAll(
                  ':id',
                  exam.id?.toString() ?? '0',
                ),
              ),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          children: [
            Row(
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
                        du.AppDateUtils.formatWeekday(exam.examDate),
                        style: TextStyle(
                          color: isUrgent
                              ? AppColors.accent
                              : AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${exam.examDate.day}',
                        style: TextStyle(
                          color: isUrgent
                              ? AppColors.accent
                              : AppColors.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          fontFeatures:
                              const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        monthAbr,
                        style: TextStyle(
                          color: isUrgent
                              ? AppColors.accent
                              : AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
                        exam.title,
                        style: AppTextStyles.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text('${exam.type.name} • $daysLabel',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isUrgent
                                ? AppColors.accent
                                : (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary),
                            fontWeight:
                                isUrgent ? FontWeight.w700 : FontWeight.w500,
                          )),
                      const SizedBox(height: 6),
                      DeadlineBucketChip(date: exam.examDate),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.insights_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  l10n.examPreparationCta,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: ThemeColors.textSecondary(context),
                ),
              ],
            ),
          ],
        ),
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