import 'package:flutter/material.dart';

import '../../../core/l10n.dart' show AppLocalizationsX, AppLocalizationsBangla;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';

class RecentActivity {
  final IconData icon;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  const RecentActivity({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });
}

class RecentActivityStrip extends StatelessWidget {
  const RecentActivityStrip({super.key, required this.items});
  final List<RecentActivity> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isBangla = l10n.isBangla;
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(isBangla ? 'সাম্প্রতিক কার্যকলাপ' : 'Recent activity',
              style: TextStyle(
                  color: ThemeColors.textSecondary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 8),
        ...items.take(3).map((it) => _ActivityTile(activity: it)),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});
  final RecentActivity activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(activity.icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                Text(activity.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        color: ThemeColors.textSecondary(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}