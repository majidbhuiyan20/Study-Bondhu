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
            .getDailyTotals(365),
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
                    Row(
                      children: [
                        Icon(Icons.calendar_view_month_rounded,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          l10n.isBangla
                              ? 'বার্ষিক অবদান'
                              : '365-day contribution',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.isBangla
                          ? 'গত ৫৩ সপ্তাহের পড়ার তীব্রতা'
                          : 'Last 53 weeks of study intensity',
                      style: TextStyle(
                          fontSize: 12,
                          color: ThemeColors.textSecondary(context)),
                    ),
                    const SizedBox(height: 12),
                    _YearHeatmap365(
                      dailySeconds: byDay,
                      goalSec: goalSec,
                    ),
                    const SizedBox(height: 10),
                    _Legend365(),
                  ],
                ),
              ),
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

// ---------------------------------------------------------------------
// GitHub-style 365-day contribution heatmap (53 weeks × 7 days).
// ---------------------------------------------------------------------

class _YearHeatmap365 extends StatefulWidget {
  const _YearHeatmap365({
    required this.dailySeconds,
    required this.goalSec,
  });
  final Map<DateTime, int> dailySeconds;
  final int goalSec;

  @override
  State<_YearHeatmap365> createState() => _YearHeatmap365State();
}

class _YearHeatmap365State extends State<_YearHeatmap365> {
  /// Day being inspected in the tooltip overlay. Null = no tooltip.
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    // Build 53 columns (weeks) of 7 cells (Mon..Sun). The last column is
    // the current week. Older weeks go further back.
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    // Anchor: the start of the current week (Monday).
    final mondayOfThisWeek =
        todayKey.subtract(Duration(days: (todayKey.weekday + 6) % 7));
    // Total cells: 53 weeks × 7 days = 371. We render 371 and hide
    // future days within the current week + any days beyond 365 by
    // colouring them as transparent placeholders.
    const totalWeeks = 53;
    const cellSize = 13.0;
    const cellGap = 3.0;
    const weekdayLabelWidth = 22.0;

    final monthsBn = const [
      'জান', 'ফেব', 'মার্চ', 'এপ্রি', 'মে', 'জুন',
      'জুলা', 'আগ', 'সেপ্ট', 'অক্টো', 'নভে', 'ডিসে',
    ];
    final monthsEn = const [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final months = l10n.isBangla ? monthsBn : monthsEn;

    // Build cells: cell at (week, weekday) where weekday 0=Mon..6=Sun.
    final cells = <_CellData>[];
    int activeDays = 0;
    int totalDays = 0;
    int bestSeconds = 0;
    for (int w = 0; w < totalWeeks; w++) {
      for (int d = 0; d < 7; d++) {
        // (col=w, row=d) maps to: mondayOfThisWeek - (52-w) weeks + d days
        final day = mondayOfThisWeek
            .subtract(Duration(days: (totalWeeks - 1 - w) * 7))
            .add(Duration(days: d));
        // Skip future days in the current week.
        if (day.isAfter(todayKey)) {
          cells.add(_CellData(date: day, seconds: 0, isFuture: true));
          continue;
        }
        // Only count days within the last 365 days (inclusive).
        final ageInDays = todayKey.difference(day).inDays;
        if (ageInDays >= 365) {
          cells.add(_CellData(date: day, seconds: 0, isOutOfRange: true));
          continue;
        }
        final sec = widget.dailySeconds[day] ?? 0;
        totalDays++;
        if (sec > 0) activeDays++;
        if (sec > bestSeconds) bestSeconds = sec;
        cells.add(_CellData(date: day, seconds: sec));
      }
    }

    // Month labels: place each month name at the column whose first row
    // (Monday) belongs to that month. If two months collide on the same
    // column we space them by skipping a column.
    final monthLabels = <_MonthLabel>[];
    int? lastMonth;
    int? lastLabelCol;
    for (int w = 0; w < totalWeeks; w++) {
      // Use the first row (Mon) of this week for label placement.
      final monday = mondayOfThisWeek
          .subtract(Duration(days: (totalWeeks - 1 - w) * 7));
      if (lastMonth == null) {
        monthLabels.add(_MonthLabel(col: w, text: months[monday.month - 1]));
        lastMonth = monday.month;
        lastLabelCol = w;
      } else if (monday.month != lastMonth) {
        if (lastLabelCol != null && (w - lastLabelCol) < 2) {
          // Skip — too close to previous label.
        } else {
          monthLabels
              .add(_MonthLabel(col: w, text: months[monday.month - 1]));
          lastMonth = monday.month;
          lastLabelCol = w;
        }
      }
    }

    final weekdayLabelsEn = const ['Mon', 'Wed', 'Fri'];
    final weekdayLabelsBn = const ['সোম', 'বুধ', 'শুক্র'];

    _CellData? selectedCell;
    if (_selected != null) {
      for (final c in cells) {
        if (c.date == _selected) {
          selectedCell = c;
          break;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month labels row.
        Padding(
          padding: const EdgeInsets.only(left: weekdayLabelWidth),
          child: SizedBox(
            height: 14,
            child: Stack(
              children: [
                for (final ml in monthLabels)
                  Positioned(
                    left: ml.col * (cellSize + cellGap),
                    child: Text(
                      ml.text,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.textSecondary(context),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Grid: weekday labels on left, weeks as columns.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekday label column.
            SizedBox(
              width: weekdayLabelWidth,
              child: Column(
                children: [
                  for (int d = 0; d < 7; d++)
                    SizedBox(
                      height: cellSize + cellGap,
                      child: d.isEven
                          ? Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                l10n.isBangla
                                    ? weekdayLabelsBn[d ~/ 2]
                                    : weekdayLabelsEn[d ~/ 2],
                                style: TextStyle(
                                  fontSize: 9,
                                  color:
                                      ThemeColors.textSecondary(context),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
            // Scrollable heatmap grid. `reverse: true` flips the
            // scroll axis so the newest week lands on the LEFT edge
            // (matching GitHub's "scroll right to go back in time"
            // intuition once users start scrolling).
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: SizedBox(
                  width: totalWeeks * (cellSize + cellGap),
                  height: 7 * (cellSize + cellGap),
                  child: Stack(
                    children: [
                      for (int w = 0; w < totalWeeks; w++)
                        for (int d = 0; d < 7; d++)
                          Positioned(
                            left: w * (cellSize + cellGap),
                            top: d * (cellSize + cellGap),
                            child: _buildCell(
                              cell: cells[w * 7 + d],
                              isDark: isDark,
                              isSelected: _selected ==
                                  cells[w * 7 + d].date,
                              onTap: () => setState(() {
                                final c = cells[w * 7 + d];
                                if (c.isFuture || c.isOutOfRange) {
                                  _selected = null;
                                } else if (_selected == c.date) {
                                  _selected = null;
                                } else {
                                  _selected = c.date;
                                }
                              }),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (selectedCell != null)
          _Tooltip(date: selectedCell.date, seconds: selectedCell.seconds),
        // Footer summary stats.
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              _SummaryStat(
                icon: Icons.event_available_rounded,
                label: l10n.isBangla ? 'সক্রিয় দিন' : 'Active days',
                value: '$activeDays / $totalDays',
              ),
              _SummaryStat(
                icon: Icons.local_fire_department_rounded,
                label: l10n.isBangla ? 'সর্বোচ্চ' : 'Best day',
                value: bestSeconds == 0
                    ? '—'
                    : '${(bestSeconds / 60).round()} min',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCell({
    required _CellData cell,
    required bool isDark,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    if (cell.isFuture || cell.isOutOfRange) {
      return const SizedBox(width: 13, height: 13);
    }
    final color = _intensityColor(cell.seconds, widget.goalSec, isDark);
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    final isToday = cell.date == todayKey;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 13,
        height: 13,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
          border: isToday
              ? Border.all(color: AppColors.primary, width: 1.2)
              : (isSelected
                  ? Border.all(
                      color: ThemeColors.textPrimary(context), width: 1.2)
                  : null),
        ),
      ),
    );
  }

  Color _intensityColor(int sec, int goalSec, bool isDark) {
    if (sec <= 0) {
      return isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;
    }
    if (goalSec <= 0) {
      return isDark ? AppColors.primaryDeep : AppColors.primary;
    }
    final pct = sec / goalSec;
    if (pct >= 1.0) {
      return isDark ? AppColors.primaryDeep : AppColors.primary;
    }
    if (pct >= 0.5) {
      return isDark
          ? AppColors.primaryDeep.withValues(alpha: 0.55)
          : AppColors.primary.withValues(alpha: 0.55);
    }
    return isDark
        ? AppColors.primaryDeep.withValues(alpha: 0.25)
        : AppColors.primary.withValues(alpha: 0.20);
  }
}

class _CellData {
  const _CellData({
    required this.date,
    required this.seconds,
    this.isFuture = false,
    this.isOutOfRange = false,
  });
  final DateTime date;
  final int seconds;
  final bool isFuture;
  final bool isOutOfRange;
}

class _MonthLabel {
  const _MonthLabel({required this.col, required this.text});
  final int col;
  final String text;
}

class _Tooltip extends StatelessWidget {
  const _Tooltip({required this.date, required this.seconds});
  final DateTime date;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mins = (seconds / 60).round();
    final isBn = l10n.isBangla;
    final monthsBn = const [
      'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
      'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
    ];
    final monthsEn = const [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final months = isBn ? monthsBn : monthsEn;
    final weekday = isBn
        ? const ['সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি', 'রবি']
        : const [
            'Monday', 'Tuesday', 'Wednesday', 'Thursday',
            'Friday', 'Saturday', 'Sunday'
          ];
    final dateLabel =
        '${weekday[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
    final studyLabel = seconds == 0
        ? (isBn ? 'কোনো পড়া হয়নি' : 'No study logged')
        : (isBn ? '$mins মিনিট পড়েছেন' : '$mins minutes studied');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurfaceVariant
            : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            seconds == 0
                ? Icons.bedtime_outlined
                : Icons.timer_outlined,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600),
                ),
                Text(
                  studyLabel,
                  style: TextStyle(
                      fontSize: 11,
                      color: ThemeColors.textSecondary(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
              fontSize: 11, color: ThemeColors.textSecondary(context)),
        ),
        Text(
          value,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _Legend365 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final none =
        isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;
    final low = isDark
        ? AppColors.primaryDeep.withValues(alpha: 0.25)
        : AppColors.primary.withValues(alpha: 0.20);
    final mid = isDark
        ? AppColors.primaryDeep.withValues(alpha: 0.55)
        : AppColors.primary.withValues(alpha: 0.55);
    final goal = isDark ? AppColors.primaryDeep : AppColors.primary;
    return Row(
      children: [
        Text(
          l10n.isBangla ? 'কম' : 'Less',
          style: const TextStyle(fontSize: 10),
        ),
        const SizedBox(width: 4),
        _swatchCell(none),
        _swatchCell(low),
        _swatchCell(mid),
        _swatchCell(goal),
        const SizedBox(width: 4),
        Text(
          l10n.isBangla ? 'বেশি' : 'More',
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Widget _swatchCell(Color c) => Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}
