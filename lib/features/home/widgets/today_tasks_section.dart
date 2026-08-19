import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/theme/app_text_styles.dart';
import '../../assignments/models/assignment.dart';
import '../../assignments/widgets/assignment_card.dart';

class TodayTasksSection extends StatelessWidget {
  const TodayTasksSection({super.key, required this.tasks});
  final List<Assignment> tasks;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (tasks.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(l10n.todayTasks, style: AppTextStyles.titleLarge),
        ),
        const SizedBox(height: 8),
        ...tasks.take(3).map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AssignmentCard(assignment: t),
            )),
        if (tasks.length > 3)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => context.push(AppRoutes.assignments),
              child: Text(l10n.seeAll),
            ),
          ),
      ],
    );
  }
}