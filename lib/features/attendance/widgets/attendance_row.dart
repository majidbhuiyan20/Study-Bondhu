import 'package:flutter/material.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../subjects/models/subject.dart';
import '../models/attendance_record.dart';
import '../repositories/attendance_repository.dart';
import 'scenario_sheet.dart';

/// Per-subject attendance card. Shows Present / Absent / Total counts,
/// the running percent, the target, three quick-mark buttons, and a
/// "View scenarios" affordance that opens a bottom sheet.
class AttendanceRow extends StatelessWidget {
  const AttendanceRow({
    super.key,
    required this.subject,
    required this.stats,
    required this.onMark,
  });

  final Subject subject;
  final AttendanceStats stats;
  final void Function(AttendanceStatus status) onMark;

  Color _percentColor(BuildContext context) {
    if (stats.total == 0) return ThemeColors.textSecondary(context);
    if (stats.percent >= subject.targetAttendance) return AppColors.success;
    if (stats.percent >= subject.targetAttendance - 10) {
      return AppColors.warning;
    }
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = _percentColor(context);
    final target = subject.targetAttendance.round();
    final hasAnyData = stats.total > 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header: name + percent ───
          Row(
            children: [
              Expanded(
                child: Text(
                  subject.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${stats.percent.round()}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.targetPercent}: $target%'
            '${hasAnyData ? ' • ${stats.present + stats.late}/${stats.total} ${l10n.attendedLabel}' : ''}',
            style: TextStyle(
              color: ThemeColors.textSecondary(context),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          // ─── Counts: Present / Absent / Total ───
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  label: l10n.present,
                  value: stats.present,
                  color: AppColors.success,
                  align: TextAlign.start,
                ),
              ),
              _StatDivider(),
              Expanded(
                child: _StatCell(
                  label: l10n.absent,
                  value: stats.absent,
                  color: AppColors.error,
                  align: TextAlign.center,
                ),
              ),
              _StatDivider(),
              Expanded(
                child: _StatCell(
                  label: 'Total',
                  value: stats.total,
                  color: ThemeColors.textPrimary(context),
                  align: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ─── Quick-mark buttons ───
          Row(
            children: [
              Expanded(
                child: _MarkButton(
                  label: l10n.markPresent,
                  color: AppColors.success,
                  onTap: () => onMark(AttendanceStatus.present),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MarkButton(
                  label: l10n.markLate,
                  color: AppColors.warning,
                  onTap: () => onMark(AttendanceStatus.late),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MarkButton(
                  label: l10n.markAbsent,
                  color: AppColors.error,
                  onTap: () => onMark(AttendanceStatus.absent),
                ),
              ),
            ],
          ),
          // ─── Scenarios affordance ───
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: hasAnyData
                  ? () => showScenariosSheet(
                        context,
                        subject: subject,
                        stats: stats,
                      )
                  : null,
              icon: const Icon(Icons.insights_outlined, size: 18),
              label: Text(l10n.viewScenarios),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.color,
    required this.align,
  });

  final String label;
  final int value;
  final Color color;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align == TextAlign.start
          ? CrossAxisAlignment.start
          : align == TextAlign.end
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.center,
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: ThemeColors.textSecondary(context),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: ThemeColors.border(context),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _MarkButton extends StatelessWidget {
  const _MarkButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}