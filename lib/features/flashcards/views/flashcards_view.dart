import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../view_models/flashcards_view_model.dart';
import 'flashcard_deck_view.dart';

class FlashcardsView extends ConsumerStatefulWidget {
  const FlashcardsView({super.key});

  @override
  ConsumerState<FlashcardsView> createState() => _FlashcardsViewState();
}

class _FlashcardsViewState extends ConsumerState<FlashcardsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(flashcardsViewModelProvider.notifier).bootstrap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(flashcardsViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.flashcards)),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab-flashcards',
        onPressed: () => context.push(AppRoutes.flashcardDeckAdd),
        child: const Icon(Icons.add),
      ),
      body: state.isLoading
          ? const AppLoading()
          : state.decks.isEmpty
              ? AppEmptyState(
                  title: l10n.noFlashcards,
                  message: l10n.flashcardsHint,
                  icon: Icons.style_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.decks.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final d = state.decks[i];
                    return AppCard(
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FlashcardDeckView(deck: d),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.style),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(d.name,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
