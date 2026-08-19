import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla,AppLocalizationsCamelCase;
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../models/topic.dart';
import '../../view_models/subjects_view_model.dart';
import 'subject_detail_widgets.dart' show AddTopicSheet, StatusDot, StatusChip;

/// Spec 03 §"Topics tab" + Spec 05 — list of topics with status chips.
class SubjectTopicsView extends ConsumerWidget {
  const SubjectTopicsView({super.key, required this.subjectId});

  final int subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(topicsForSubjectProvider(subjectId));
    return async.when(
      loading: () => const AppLoading(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (topics) => _TopicsList(topics: topics, subjectId: subjectId),
    );
  }
}

class _TopicsList extends ConsumerWidget {
  const _TopicsList({required this.topics, required this.subjectId});
  final List<Topic> topics;
  final int subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (topics.isEmpty) {
      return AppEmptyState(
        title: l10n.noTopics,
        message: l10n.noTopicsHint,
        icon: Icons.checklist_outlined,
        actionLabel: l10n.addTopic,
        onAction: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (ctx) => AddTopicSheet(subjectId: subjectId),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: topics.length,
      separatorBuilder: (_, i) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final t = topics[i];
        return AppCard(
          onTap: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (ctx) => AddTopicSheet(subjectId: subjectId, existing: t),
          ),
          child: Row(
            children: [
              StatusDot(status: t.status),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        decoration:
                            t.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.isBangla ? t.status.bn : t.status.en,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: ThemeColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(status: t.status),
            ],
          ),
        );
      },
    );
  }
}
