import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../subjects/models/subject.dart';
import '../repositories/attendance_repository.dart';

/// Opens a bottom sheet showing "you can miss N more classes" projection
/// for the given subject. Returns when the user dismisses the sheet.
///
/// Math (per spec #17):
///   maxAbsents = floor((totalClasses * target) / 100) - presentClasses
/// then clamped to >= 0. "Late" is not counted toward present in this
/// formula — it is a softer penalty than "absent".
Future<void> showScenariosSheet(
  BuildContext context, {
  required Subject subject,
  required AttendanceStats stats,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _ScenarioSheet(subject: subject, stats: stats),
  );
}

/// Pure math helper, exposed for testing / reuse.
int maxAbsentsFor({
  required int totalClasses,
  required num target,
  required int present,
}) {
  if (totalClasses <= 0 || target <= 0) return 0;
  final raw = (present * 100 / target).floor() - totalClasses;
  return raw < 0 ? 0 : raw;
}

class _ScenarioSheet extends StatelessWidget {
  const _ScenarioSheet({required this.subject, required this.stats});

  final Subject subject;
  final AttendanceStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final target = subject.targetAttendance.round();

    final hasData = stats.total > 0;
    final skips = hasData
        ? maxAbsentsFor(
            totalClasses: stats.total,
            target: subject.targetAttendance,
            present: stats.present,
          )
        : 0;

    // Projection: what % would attendance be after missing one more class?
    // present + late are "kept" classes; total + 1 is the new denominator.
    final nextPct = hasData
        ? ((stats.present + stats.late) / (stats.total + 1)) * 100
        : 0.0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: ThemeColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              subject.name,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.targetPercent}: $target%',
              style: TextStyle(
                color: ThemeColors.textSecondary(context),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            if (!hasData)
              _HintBox(
                icon: Icons.info_outline,
                color: AppColors.info,
                text:
                    'Log some classes first to see what-if scenarios.',
              )
            else ...[
              _SkipsCard(
                skips: skips,
                target: target,
                accent: skips > 0 ? AppColors.success : AppColors.warning,
                icon: skips > 0
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_outlined,
              ),
              const SizedBox(height: 16),
              _NextMissLine(nextPct: nextPct, target: target),
            ],
            const SizedBox(height: 20),
            AppButton(
              label: l10n.closeButton,
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

/// "You can miss **N** more classes and stay above **T**%."
class _SkipsCard extends StatelessWidget {
  const _SkipsCard({
    required this.skips,
    required this.target,
    required this.accent,
    required this.icon,
  });

  final int skips;
  final int target;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: ThemeColors.textPrimary(context),
                  fontSize: 15,
                  height: 1.35,
                ),
                children: [
                  const TextSpan(text: 'You can miss '),
                  TextSpan(
                    text: '$skips',
                    style: TextStyle(
                      color: accent,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const TextSpan(text: ' more '),
                  TextSpan(
                    text: skips == 1 ? 'class' : 'classes',
                  ),
                  TextSpan(
                    text: '\nand stay above ',
                  ),
                  TextSpan(
                    text: '$target%',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextMissLine extends StatelessWidget {
  const _NextMissLine({required this.nextPct, required this.target});

  final double nextPct;
  final int target;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final willStayAbove = nextPct >= target;
    final color = willStayAbove ? AppColors.success : AppColors.error;
    final pct = math.max(0, nextPct).round();
    final text = willStayAbove
        ? 'Stay at $pct% even if you miss the next class.'
        : l10n.scenarioWillDrop.replaceAll('%d', '$pct');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            willStayAbove ? Icons.trending_flat : Icons.trending_down,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: ThemeColors.textPrimary(context),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HintBox extends StatelessWidget {
  const _HintBox({
    required this.icon,
    required this.color,
    required this.text,
  });
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: ThemeColors.textPrimary(context),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}