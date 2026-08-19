import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla,AppLocalizationsCamelCase;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/duration_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../view_models/home_view_model.dart';

class TodayProgressCard extends StatelessWidget {
  const TodayProgressCard({super.key, required this.state});
  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pct = state.dailyProgress.clamp(0.0, 1.0);
    final studied = Duration(seconds: state.todaySeconds);
    final reachedGoal = pct >= 1.0;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.todaysProgress,
                  style: AppTextStyles.titleMedium),
              const Spacer(),
              _StreakChip(streakDays: state.streakDays),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                DurationUtils.formatHuman(studied),
                style: AppTextStyles.numericHuge,
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  l10n.isBangla
                      ? '/ ${state.dailyGoalMinutes} মি'
                      : '/ ${state.dailyGoalMinutes}m',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: ThemeColors.textSecondary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppProgressBar(
            value: pct,
            height: 10,
            color: reachedGoal ? AppColors.success : AppColors.primary,
          ),
          const SizedBox(height: 6),
          Text(
            reachedGoal
                ? l10n.goalReachedToday
                : '${(pct * 100).round()}${l10n.percentOfDailyGoal}',
            style: AppTextStyles.bodySmall.copyWith(
              color: ThemeColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.streakDays});
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tooltip = l10n.isBangla ? 'ধারা দেখুন' : 'View streak';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => context.push(AppRoutes.streak),
        child: Tooltip(
          message: tooltip,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.accent.withValues(alpha: 0.18)
                  : AppColors.accentLight,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department,
                    size: 14, color: AppColors.accent),
                const SizedBox(width: 4),
                Text(
                  l10n.isBangla
                      ? '$streakDays দি'
                      : '${streakDays}d',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
