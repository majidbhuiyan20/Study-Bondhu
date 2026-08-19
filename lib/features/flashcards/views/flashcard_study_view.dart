import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla;
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../models/flashcard.dart';
import '../view_models/flashcards_view_model.dart';

class FlashcardStudyView extends ConsumerStatefulWidget {
  const FlashcardStudyView({super.key, required this.deck});
  final FlashcardDeck deck;

  @override
  ConsumerState<FlashcardStudyView> createState() => _State();
}

class _State extends ConsumerState<FlashcardStudyView> {
  List<Flashcard> _cards = [];
  int _index = 0;
  bool _showBack = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cards = await ref
        .read(flashcardsViewModelProvider.notifier)
        .getCards(widget.deck.id!);
    if (!mounted) return;
    setState(() {
      _cards = cards;
      _loading = false;
    });
  }

  void _rate(int quality) async {
    final card = _cards[_index];
    await ref
        .read(flashcardsViewModelProvider.notifier)
        .recordReview(card.id!, quality);
    if (!mounted) return;
    setState(() {
      _showBack = false;
      _index++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isBn = l10n.isBangla;
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
            child: Text(isBn ? 'এই ডেকে কোনো কার্ড নেই' : 'No cards in this deck')),
      );
    }
    if (_index >= _cards.length) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle,
                  color: AppColors.success, size: 64),
              const SizedBox(height: 12),
              Text(
                isBn
                    ? '${_cards.length}টি কার্ড দেখা হয়েছে'
                    : 'Reviewed ${_cards.length} cards',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => setState(() => _index = 0),
                child: Text(isBn ? 'আবার শুরু' : 'Restart'),
              ),
            ],
          ),
        ),
      );
    }
    final card = _cards[_index];
    return Scaffold(
      appBar: AppBar(title: Text('${_index + 1}/${_cards.length}')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppCard(
                onTap: () => setState(() => _showBack = !_showBack),
                child: SizedBox(
                  height: 220,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _showBack ? card.back : card.front,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_showBack)
                Row(
                  children: [
                    _RateBtn(
                      label: isBn ? '😕 আবার' : '😕 Again',
                      color: AppColors.error,
                      onTap: () => _rate(2),
                    ),
                    const SizedBox(width: 8),
                    _RateBtn(
                      label: isBn ? '🙂 ভালো' : '🙂 Good',
                      color: AppColors.warning,
                      onTap: () => _rate(4),
                    ),
                    const SizedBox(width: 8),
                    _RateBtn(
                      label: isBn ? '😎 সহজ' : '😎 Easy',
                      color: AppColors.success,
                      onTap: () => _rate(5),
                    ),
                  ],
                )
              else
                OutlinedButton(
                  onPressed: () => setState(() => _showBack = true),
                  child: Text(isBn ? 'উত্তর দেখান' : 'Show answer'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RateBtn extends StatelessWidget {
  const _RateBtn(
      {required this.label,
      required this.color,
      required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: color),
        child: Text(label),
      ),
    );
  }
}