import 'package:flutter/material.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla,AppLocalizationsCamelCase;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/widgets/app_card.dart';
import '../../revision/models/revision_item.dart';

class RevisionCard extends StatelessWidget {
  const RevisionCard({super.key, required this.items});
  final List<RevisionItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(l10n.revisionQueue,
              style: AppTextStyles.titleLarge),
        ),
        const SizedBox(height: 8),
        ...items.take(2).map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                child: Row(
                  children: [
                    const Icon(Icons.refresh,
                        color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.isBangla
                            ? 'রিভিশন ${du.AppDateUtils.relative(r.scheduledDate)}'
                            : 'Revision ${du.AppDateUtils.relative(r.scheduledDate)}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        color: ThemeColors.textSecondary(context)),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}