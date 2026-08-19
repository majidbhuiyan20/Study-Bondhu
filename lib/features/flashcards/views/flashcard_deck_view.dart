import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../models/flashcard.dart';
import '../view_models/flashcards_view_model.dart';
import 'flashcard_study_view.dart';

class FlashcardDeckView extends ConsumerWidget {
  const FlashcardDeckView({super.key, required this.deck});
  final FlashcardDeck deck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(deck.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FlashcardStudyView(deck: deck),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              if (deck.id != null) {
                await ref
                    .read(flashcardsViewModelProvider.notifier)
                    .deleteDeck(deck.id!);
              }
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab-flashcard-deck-${deck.id ?? 'new'}',
        onPressed: () => _showAddCard(context, ref),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Flashcard>>(
        future:
            ref.read(flashcardsViewModelProvider.notifier).getCards(deck.id!),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final cards = snap.data!;
          if (cards.isEmpty) {
            return AppEmptyState(
              title: 'No cards',
              message: 'Tap + to add flashcards',
              icon: Icons.style_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final c = cards[i];
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Front',
                        style: TextStyle(
                            color: ThemeColors.textSecondary(context),
                            fontSize: 11)),
                    Text(c.front,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('Back',
                        style: TextStyle(
                            color: ThemeColors.textSecondary(context),
                            fontSize: 11)),
                    Text(c.back,
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddCard(BuildContext context, WidgetRef ref) {
    final front = TextEditingController();
    final back = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: front,
              decoration:
                  const InputDecoration(hintText: 'Front (question)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: back,
              decoration: const InputDecoration(hintText: 'Back (answer)'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () async {
                    if (front.text.trim().isEmpty ||
                        back.text.trim().isEmpty) {
                      return;
                    }
                    await ref
                        .read(flashcardsViewModelProvider.notifier)
                        .addCard(Flashcard(
                          deckId: deck.id!,
                          front: front.text.trim(),
                          back: back.text.trim(),
                          createdAt: DateTime.now(),
                        ));
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}