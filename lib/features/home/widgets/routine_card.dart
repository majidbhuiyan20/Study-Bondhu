import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../routines/models/routine.dart';
import '../../routines/view_models/routines_view_model.dart';

class RoutinesHomeSection extends ConsumerWidget {
  const RoutinesHomeSection({super.key, required this.routines});
  final List<Routine> routines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (routines.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text(context.l10n.todaysRoutines,
                  style: AppTextStyles.titleLarge),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('${routines.length}',
                    style: const TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    )),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...routines.take(3).map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                onTap: () => ref
                    .read(routinesViewModelProvider.notifier)
                    .markDone(r.id!),
                child: Row(
                  children: [
                    const Icon(Icons.repeat_rounded,
                        color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.title,
                              style: AppTextStyles.titleSmall),
                          if (r.timeOfDay != null) ...[
                            const SizedBox(height: 2),
                            Text('⏰ ${r.timeOfDay!}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color:
                                      ThemeColors.textSecondary(context),
                                )),
                          ],
                        ],
                      ),
                    ),
                    Icon(Icons.check_circle_outline,
                        color: ThemeColors.textSecondary(context)),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class RoutinesEmptyHint extends StatelessWidget {
  const RoutinesEmptyHint({super.key});
  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: 'No routines yet',
      message:
          'Add a daily or weekly routine (e.g. "Read Bangla 30 min") to keep your habits on track',
      icon: Icons.repeat_rounded,
    );
  }
}