import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla,AppLocalizationsCamelCase;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/quick_add_sheet.dart';
import '../view_models/notes_view_model.dart';
import 'note_editor_view.dart';

class NotesView extends ConsumerStatefulWidget {
  const NotesView({super.key});

  @override
  ConsumerState<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends ConsumerState<NotesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(notesViewModelProvider.notifier).bootstrap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(notesViewModelProvider);
    // Pinned notes sticky at top; the rest keep repository order
    // (most-recently-updated first).
    final sorted = [...state.notes]..sort((a, b) {
        if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notes)),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab-notes',
        onPressed: () => QuickAddSheet.show(context),
        child: const Icon(Icons.add),
      ),
      body: state.isLoading
          ? const AppLoading()
          : sorted.isEmpty
              ? AppEmptyState(
                  title: l10n.noNotes,
                  message: l10n.notesHint,
                  icon: Icons.note_alt_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: sorted.length,
                  separatorBuilder: (_, i) =>
                      const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final n = sorted[i];
                    return AppCard(
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => NoteEditorView(note: n),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(n.title,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              IconButton(
                                tooltip: n.isPinned ? 'Unpin' : 'Pin',
                                icon: Icon(
                                  n.isPinned
                                      ? Icons.push_pin
                                      : Icons.push_pin_outlined,
                                  size: 18,
                                  color: n.isPinned
                                      ? AppColors.primary
                                      : ThemeColors.textSecondary(context),
                                ),
                                onPressed: () => ref
                                    .read(notesViewModelProvider.notifier)
                                    .togglePin(n),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(n.body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: ThemeColors.textSecondary(context),
                                  fontSize: 13)),
                          const SizedBox(height: 6),
                          Text(
                              l10n.isBangla
                                  ? 'হালনাগাদ ${du.AppDateUtils.relative(n.updatedAt)}'
                                  : 'Updated ${du.AppDateUtils.relative(n.updatedAt)}',
                              style: TextStyle(
                                  color: ThemeColors.textTertiary(context),
                                  fontSize: 11)),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
