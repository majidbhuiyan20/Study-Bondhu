import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/providers.dart';
import '../../subjects/models/subject.dart';
import '../view_models/analytics_view_model.dart';

/// "Derived insights" section (spec #15). Shows the most-studied subject,
/// least-studied subject, most productive day of the week, total completed
/// topics, and revision count — each rendered as a small labelled row.
class InsightsSection extends ConsumerWidget {
  const InsightsSection({super.key, required this.insights});

  final AnalyticsInsights insights;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (insights.isEmpty) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Insights will appear once you have some study data.',
            style: TextStyle(
              color: ThemeColors.textSecondary(context),
            ),
          ),
        ),
      );
    }
    final subjectsAsync = ref.watch(_subjectsProvider);
    final subjects = subjectsAsync.maybeWhen(
      data: (s) => s,
      orElse: () => const <Subject>[],
    );
    final byId = {for (final s in subjects) s.id: s};
    final isBn = context.l10n.isBangla;

    final rows = <Widget>[];

    final most = insights.mostStudiedSubjectId;
    if (most != null && byId[most] != null) {
      rows.add(_InsightRow(
        icon: Icons.trending_up_rounded,
        color: AppColors.success,
        label: isBn ? 'সবচেয়ে বেশি পড়া বিষয়' : 'Most studied subject',
        value: byId[most]!.name,
      ));
    }

    final least = insights.leastStudiedSubjectId;
    if (least != null && byId[least] != null && least != most) {
      rows.add(_InsightRow(
        icon: Icons.trending_down_rounded,
        color: AppColors.warning,
        label: isBn ? 'একটু কম পড়া হয়েছে' : 'Least studied subject',
        value: byId[least]!.name,
      ));
    }

    final dow = insights.mostProductiveWeekday;
    if (dow != null) {
      rows.add(_InsightRow(
        icon: Icons.calendar_today_rounded,
        color: AppColors.info,
        label: isBn ? 'সবচেয়ে প্রডাক্টিভ দিন' : 'Most productive day',
        value: _weekdayLabel(dow, isBn),
      ));
    }

    rows.add(_InsightRow(
      icon: Icons.check_circle_outline_rounded,
      color: AppColors.primary,
      label: isBn ? 'মোট দক্ষ বিষয়' : 'Completed topics',
      value: '${insights.completedTopics}',
    ));

    rows.add(_InsightRow(
      icon: Icons.replay_rounded,
      color: AppColors.accent,
      label: isBn ? 'রিভিশন সেশন' : 'Revisions',
      value: '${insights.revisionCount}',
    ));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1) const Divider(height: 12),
          ],
        ],
      ),
    );
  }

  static String _weekdayLabel(int weekday, bool isBn) {
    if (isBn) {
      const names = [
        '', // DateTime.weekday is 1..7, index 0 unused
        'সোমবার',
        'মঙ্গলবার',
        'বুধবার',
        'বৃহস্পতিবার',
        'শুক্রবার',
        'শনিবার',
        'রবিবার',
      ];
      return (weekday >= 1 && weekday <= 7) ? names[weekday] : '';
    }
    const names = [
      '', // 1..7
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return (weekday >= 1 && weekday <= 7) ? names[weekday] : '';
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color: ThemeColors.textSecondary(context), fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

final _subjectsProvider = FutureProvider((ref) async {
  return ref.watch(subjectsRepositoryProvider).getSubjects();
});
