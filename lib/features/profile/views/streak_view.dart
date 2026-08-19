import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla,AppLocalizationsCamelCase;
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../settings/view_models/settings_view_model.dart';
import '../../study/repositories/study_repository.dart' show DailyStudySummary;

/// Spec #23 — full streak view with monthly calendar heatmap.
class StreakView extends ConsumerStatefulWidget {
  const StreakView({super.key});

  @override
  ConsumerState<StreakView> createState() => _StreakViewState();
}

class _StreakViewState extends ConsumerState<StreakView> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsViewModelProvider);
    final goalMin = settings.dailyGoalMinutes;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.streakLabel)),
      body: FutureBuilder<List<DailyStudySummary>>(
        future: ref
            .read(studyRepositoryProvider)
            .getDailyTotals(90),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final daily = snap.data ?? const <DailyStudySummary>[];
          final byDay = {
            for (final d in daily)
              DateTime(d.date.year, d.date.month, d.date.day): d.seconds,
          };
          final streak = _computeStreak(byDay, goalMin);
          final goalSec =
              Duration(minutes: goalMin.clamp(1, 1440)).inSeconds;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StreakHeader(streak: streak, isBroken: streak == 0),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MonthBar(
                      month: _month,
                      onPrev: () => _shiftMonth(-1),
                      onNext: _isCurrentMonth(_month)
                          ? null
                          : () => _shiftMonth(1),
                    ),
                    const SizedBox(height: 12),
                    _StreakHeatmap(
                      month: _month,
                      dailySeconds: byDay,
                      goalSec: goalSec,
                    ),
                    const SizedBox(height: 12),
                    _Legend(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      l10n.isBangla
                          ? 'দৈনিক লক্ষ্য: $goalMin মিনিট'
                          : 'Daily goal: $goalMin min',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  bool _isCurrentMonth(DateTime m) {
    final now = DateTime.now();
    return m.year == now.year && m.month == now.month;
  }

  /// Consecutive days, ending today, where study time met the daily goal.
  /// Today is skipped if it hasn't met the goal yet.
  int _computeStreak(Map<DateTime, int> byDay, int goalMin) {
    final threshold = Duration(minutes: goalMin.clamp(1, 1440)).inSeconds;
    final today = DateTime.now();
    final cursor = DateTime(today.year, today.month, today.day);
    int streak = 0;
    for (int i = 0; i < 60; i++) {
      final d = cursor.subtract(Duration(days: i));
      final sec = byDay[d] ?? 0;
      if (sec >= threshold) {
        streak++;
      } else if (i == 0) {
        // Today not yet met — keep looking backwards.
        continue;
      } else {
        break;
      }
    }
    return streak;
  }
}

class _StreakHeader extends StatelessWidget {
  const _StreakHeader({required this.streak, required this.isBroken});
  final int streak;
  final bool isBroken;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isBroken ? AppColors.warning : AppColors.accent;
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.local_fire_department,
                color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBroken
                      ? (l10n.isBangla
                          ? 'নতুন ধারা শুরু করুন'
                          : 'Start a new streak today')
                      : (l10n.isBangla
                          ? '$streak দিনের ধারা'
                          : '$streak day streak'),
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  isBroken
                      ? (l10n.isBangla
                          ? 'আজ একটু পড়লেই আবার শুরু!'
                          : 'A small session today restarts it!')
                      : (l10n.isBangla
                          ? 'দারুণ চালিয়ে যাচ্ছো — থামো না!'
                          : "Keep it up — you're on fire!"),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: ThemeColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthBar extends StatelessWidget {
  const _MonthBar({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final months = _localizedMonthNames(context);
    final label = '${months[month.month - 1]} ${month.year}';
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous month',
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Center(
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ),
        IconButton(
          tooltip: 'Next month',
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }

  List<String> _localizedMonthNames(BuildContext context) {
    if (context.l10n.isBangla) {
      return const [
        'জানুয়ারি',
        'ফেব্রুয়ারি',
        'মার্চ',
        'এপ্রিল',
        'মে',
        'জুন',
        'জুলাই',
        'আগস্ট',
        'সেপ্টেম্বর',
        'অক্টোবর',
        'নভেম্বর',
        'ডিসেম্বর',
      ];
    }
    return const [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
  }
}

class _StreakHeatmap extends StatelessWidget {
  const _StreakHeatmap({
    required this.month,
    required this.dailySeconds,
    required this.goalSec,
  });
  final DateTime month;
  final Map<DateTime, int> dailySeconds;
  final int goalSec;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Build weeks (columns) starting Monday.
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth =
        DateTime(month.year, month.month + 1, 0).day;
    // Mon=1..Sun=7. For Monday-first column.
    final leading = (firstOfMonth.weekday + 6) % 7;
    final cells = leading + daysInMonth;
    final rows = (cells / 7).ceil();

    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    final weekdayLabels = context.l10n.isBangla
        ? const ['সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি', 'রবি']
        : const ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    return Column(
      children: [
        Row(
          children: [
            for (final l in weekdayLabels)
              Expanded(
                child: Center(
                  child: Text(l,
                      style: TextStyle(
                          fontSize: 11,
                          color: ThemeColors.textSecondary(context))),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        for (int r = 0; r < rows; r++) ...[
          Row(
            children: [
              for (int c = 0; c < 7; c++) ...[
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _buildCell(
                      context: context,
                      index: r * 7 + c,
                      leading: leading,
                      daysInMonth: daysInMonth,
                      isDark: isDark,
                      todayKey: todayKey,
                    ),
                  ),
                ),
                if (c < 6) const SizedBox(width: 4),
              ],
            ],
          ),
          if (r < rows - 1) const SizedBox(height: 4),
        ],
      ],
    );
  }

  Widget _buildCell({
    required BuildContext context,
    required int index,
    required int leading,
    required int daysInMonth,
    required bool isDark,
    required DateTime todayKey,
  }) {
    final dayNum = index - leading + 1;
    if (dayNum < 1 || dayNum > daysInMonth) {
      return const SizedBox.shrink();
    }
    final d = DateTime(month.year, month.month, dayNum);
    final sec = dailySeconds[d] ?? 0;
    final color = _bucketColor(sec, goalSec, isDark);
    final isToday = d == todayKey;
    final isFuture = d.isAfter(todayKey);
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: isToday
            ? Border.all(color: AppColors.primary, width: 1.5)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '$dayNum',
        style: TextStyle(
          fontSize: 10,
          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
          color: isFuture
              ? ThemeColors.textTertiary(context)
              : (color.computeLuminance() > 0.6
                  ? AppColors.textPrimary
                  : Colors.white),
        ),
      ),
    );
  }

  Color _bucketColor(int sec, int goalSec, bool isDark) {
    if (sec == 0) {
      return isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;
    }
    if (sec >= goalSec) {
      return isDark ? AppColors.primaryDeep : AppColors.primary;
    }
    if (sec >= (goalSec * 0.5).round()) {
      // Partial — accent (warm) for visibility.
      return isDark
          ? AppColors.accent.withValues(alpha: 0.7)
          : AppColors.accentLight;
    }
    // Below 50% of goal but did study something — error tint.
    return isDark
        ? AppColors.error.withValues(alpha: 0.6)
        : AppColors.errorLight;
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color swatch(Color c) => c;
    final goal = isDark ? AppColors.primaryDeep : AppColors.primary;
    final partial = isDark
        ? AppColors.accent.withValues(alpha: 0.7)
        : AppColors.accentLight;
    final low = isDark
        ? AppColors.error.withValues(alpha: 0.6)
        : AppColors.errorLight;
    final none =
        isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;
    final l10n = context.l10n;
    return Row(
      children: [
        _swatch(swatch(goal), l10n.isBangla ? 'লক্ষ্য পূরণ' : 'Goal'),
        const SizedBox(width: 12),
        _swatch(swatch(partial), l10n.isBangla ? 'আংশিক' : 'Partial'),
        const SizedBox(width: 12),
        _swatch(swatch(low), l10n.isBangla ? 'কম' : 'Below'),
        const SizedBox(width: 12),
        _swatch(swatch(none), l10n.isBangla ? 'পড়া হয়নি' : 'None'),
      ],
    );
  }

  Widget _swatch(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
