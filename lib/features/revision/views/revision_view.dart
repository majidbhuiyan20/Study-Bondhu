import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../subjects/models/subject.dart';
import '../../subjects/models/topic.dart';
import '../models/revision_item.dart';
import '../view_models/revision_view_model.dart';

class RevisionView extends ConsumerStatefulWidget {
  const RevisionView({super.key});

  @override
  ConsumerState<RevisionView> createState() => _RevisionViewState();
}

class _RevisionViewState extends ConsumerState<RevisionView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(revisionViewModelProvider.notifier).bootstrap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(revisionViewModelProvider);

    // Surface errors from the VM as a snackbar, then clear.
    ref.listen<RevisionState>(revisionViewModelProvider, (prev, next) {
      final err = next.errorMessage;
      if (err != null && err.isNotEmpty && prev?.errorMessage != err) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(err)));
        ref.read(revisionViewModelProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.revisionSchedule)),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab-revision',
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.add),
      ),
      body: state.isLoading
          ? const AppLoading()
          : state.items.isEmpty
              ? AppEmptyState(
                  title: l10n.noRevision,
                  message:
                      'Add revisions so topics stay fresh in your memory',
                  icon: Icons.refresh_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final r = state.items[i];
                    final isMutating =
                        state.pendingMutationId != null &&
                            state.pendingMutationId == r.id;
                    return _RevisionRow(
                      item: r,
                      isMutating: isMutating,
                      onDone: r.status == RevisionStatus.pending &&
                              !isMutating
                          ? () => _showRatingSheet(context, r)
                          : null,
                      onDelete: () => r.id == null
                          ? null
                          : ref
                              .read(revisionViewModelProvider.notifier)
                              .deleteRevision(r.id!),
                    );
                  },
                ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddRevisionSheet(),
    );
  }

  Future<void> _showRatingSheet(
    BuildContext context,
    RevisionItem r,
  ) async {
    int rating = 3;
    bool submitting = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final l10n = ctx.l10n;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setSt) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.howDidItGo,
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Next revision in ${r.intervalDays} days',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: ThemeColors.textSecondary(ctx),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _RateChip(
                      label: l10n.revisionRateWeak,
                      rating: 1,
                      selected: rating == 1,
                      onTap: submitting
                          ? null
                          : () => setSt(() => rating = 1),
                    ),
                    const SizedBox(width: 8),
                    _RateChip(
                      label: l10n.revisionRateOkay,
                      rating: 3,
                      selected: rating == 3,
                      onTap: submitting
                          ? null
                          : () => setSt(() => rating = 3),
                    ),
                    const SizedBox(width: 8),
                    _RateChip(
                      label: l10n.revisionRateStrong,
                      rating: 5,
                      selected: rating == 5,
                      onTap: submitting
                          ? null
                          : () => setSt(() => rating = 5),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: submitting
                            ? null
                            : () => Navigator.pop(ctx),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: submitting
                            ? null
                            : () async {
                                setSt(() => submitting = true);
                                Navigator.pop(ctx);
                                try {
                                  await ref
                                      .read(revisionViewModelProvider
                                          .notifier)
                                      .markCompletedWithRating(r, rating);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(SnackBar(
                                        content: Text(
                                          'Failed to mark revision: $e',
                                        ),
                                      ));
                                  }
                                }
                              },
                        child: submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textOnPrimary,
                                ),
                              )
                            : Text(l10n.revisionMarkDone),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RevisionRow extends ConsumerWidget {
  const _RevisionRow({
    required this.item,
    required this.isMutating,
    required this.onDone,
    required this.onDelete,
  });

  final RevisionItem item;
  final bool isMutating;
  final VoidCallback? onDone;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(pendingRevisionSubjectsProvider);
    final topicsAsync = ref.watch(pendingRevisionTopicsProvider);
    return AppCard(
      child: Row(
        children: [
          Icon(
            item.status == RevisionStatus.completed
                ? Icons.check_circle
                : Icons.access_time,
            color: item.status == RevisionStatus.completed
                ? AppColors.success
                : AppColors.warning,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subjectsAsync.maybeWhen(
                    data: (subs) => _subjectName(subs, item),
                    orElse: () => 'Revision',
                  ),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                if (item.topicId != null)
                  topicsAsync.maybeWhen(
                    data: (topics) {
                      final found = topics[item.topicId];
                      if (found == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            Icon(
                              _topicIcon(found.status),
                              size: 12,
                              color: _topicColor(context, found.status),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              found.name,
                              style: TextStyle(
                                color: ThemeColors.textSecondary(context),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),
                Text(
                  'Due ${AppDateUtils.relative(item.scheduledDate)}',
                  style: TextStyle(
                      color: ThemeColors.textSecondary(context),
                      fontSize: 12),
                ),
              ],
            ),
          ),
          if (isMutating)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (onDone != null)
            IconButton(
              onPressed: onDone,
              icon: const Icon(Icons.check),
              tooltip: 'Mark done',
            ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
    );
  }

  String _subjectName(Map<int, Subject> subs, RevisionItem item) {
    if (item.subjectId == null) return 'General revision';
    final s = subs[item.subjectId];
    if (s == null) return 'Revision';
    return s.name;
  }

  IconData _topicIcon(TopicStatus s) {
    switch (s) {
      case TopicStatus.mastered:
        return Icons.verified_rounded;
      case TopicStatus.weak:
        return Icons.priority_high_rounded;
      case TopicStatus.learning:
        return Icons.school_rounded;
      case TopicStatus.notStarted:
        return Icons.circle_outlined;
    }
  }

  Color _topicColor(BuildContext ctx, TopicStatus s) {
    switch (s) {
      case TopicStatus.mastered:
        return AppColors.success;
      case TopicStatus.weak:
        return AppColors.error;
      case TopicStatus.learning:
        return AppColors.primary;
      case TopicStatus.notStarted:
        return ThemeColors.textSecondary(ctx);
    }
  }
}

final _subjectsProvider = FutureProvider((ref) async {
  return ref.watch(subjectsRepositoryProvider).getSubjects();
});

class _RateChip extends StatelessWidget {
  const _RateChip({
    required this.label,
    required this.rating,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final int rating;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tint = switch (rating) {
      1 => AppColors.error,
      3 => AppColors.primary,
      _ => AppColors.success,
    };
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? tint : ThemeColors.surfaceAlt(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? tint : ThemeColors.border(context),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: selected
                  ? AppColors.textOnPrimary
                  : ThemeColors.textPrimary(context),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddRevisionSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddRevisionSheet> createState() => _AddRevisionSheetState();
}

class _AddRevisionSheetState extends ConsumerState<_AddRevisionSheet> {
  int? _subjectId;
  DateTime _date = AppDateUtils.morningOf(
    DateTime.now().add(const Duration(days: 1)),
  );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate:
          DateTime.now().add(const Duration(days: 365)),
      initialDate: _date,
    );
    if (picked != null) {
      setState(() => _date = AppDateUtils.morningOf(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subjectsAsync = ref.watch(_subjectsProvider);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.revisionAddTitle,
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          subjectsAsync.when(
            data: (subs) => DropdownButtonFormField<int?>(
              initialValue: _subjectId,
              decoration:
                  InputDecoration(hintText: l10n.subject),
              items: [
                DropdownMenuItem(
                    value: null, child: Text(l10n.revisionGeneral)),
                ...subs.map((s) => DropdownMenuItem(
                    value: s.id, child: Text(s.name))),
              ],
              onChanged: (v) => setState(() => _subjectId = v),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text(
                '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickDate,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () async {
                  await ref
                      .read(revisionViewModelProvider.notifier)
                      .addRevision(RevisionItem(
                        subjectId: _subjectId,
                        scheduledDate: _date,
                        createdAt: DateTime.now(),
                      ));
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(l10n.save),
              ),
            ],
          ),
        ],
      ),
    );
  }
}