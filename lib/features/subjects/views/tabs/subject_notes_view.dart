import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../../core/providers.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading.dart';

/// Spec 03 §"Notes tab" + spec 18 — filtered list of notes. Tap a card to
/// open the editor sheet.
class SubjectNotesView extends ConsumerWidget {
  const SubjectNotesView({super.key, required this.subjectId});

  final int subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return FutureBuilder(
      future: ref.watch(notesRepositoryProvider).getNotes(subjectId: subjectId),
      builder: (context, snap) {
        if (!snap.hasData) return const AppLoading();
        final items = snap.data!;
        if (items.isEmpty) {
          return AppEmptyState(
            title: l10n.noNotes,
            message: l10n.noNotesHint,
            icon: Icons.note_alt_outlined,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, i) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final n = items[i];
            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.title,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: ThemeColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}