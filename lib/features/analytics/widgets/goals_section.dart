import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../models/goal.dart';

/// Goal list row + add affordance used by the analytics dashboard.
class GoalTile extends StatelessWidget {
  const GoalTile({super.key, required this.goal, this.onDelete});
  final Goal goal;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(goal.title,
                    style:
                        const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text('${goal.progress}/${goal.target} m',
                  style: TextStyle(
                    color: ThemeColors.textSecondary(context),
                    fontSize: 12,
                  )),
              if (onDelete != null)
                IconButton(
                  tooltip: 'Delete',
                  icon: Icon(Icons.delete_outline_rounded,
                      size: 18,
                      color: ThemeColors.textSecondary(context)),
                  onPressed: onDelete,
                ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: goal.percent.clamp(0, 1).toDouble(),
            backgroundColor: AppColors.surfaceVariant,
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          Text(goal.type.name.toUpperCase(),
              style: TextStyle(
                color: ThemeColors.textSecondary(context),
                fontSize: 11,
              )),
        ],
      ),
    );
  }
}
