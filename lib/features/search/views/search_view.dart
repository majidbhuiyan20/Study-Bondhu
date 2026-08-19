import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../assignments/repositories/assignments_repository.dart';
import '../../exams/repositories/exams_repository.dart';
import '../../flashcards/repositories/flashcards_repository.dart';
import '../../notes/repositories/notes_repository.dart';
import '../../subjects/repositories/subjects_repository.dart';

/// A grouped search hit. We surface the originating type so the UI can
/// route the user to the right detail screen.
class SearchHit {
  final SearchHitKind kind;
  final int id;
  final String title;
  final String? subtitle;
  final int? subjectId;
  const SearchHit({
    required this.kind,
    required this.id,
    required this.title,
    this.subtitle,
    this.subjectId,
  });
}

enum SearchHitKind {
  subject,
  topic,
  assignment,
  exam,
  note,
  flashcard,
}

extension SearchHitKindX on SearchHitKind {
  IconData get icon {
    switch (this) {
      case SearchHitKind.subject:
        return Icons.menu_book_rounded;
      case SearchHitKind.topic:
        return Icons.bookmark_rounded;
      case SearchHitKind.assignment:
        return Icons.assignment_rounded;
      case SearchHitKind.exam:
        return Icons.event_note_rounded;
      case SearchHitKind.note:
        return Icons.note_alt_rounded;
      case SearchHitKind.flashcard:
        return Icons.style_rounded;
    }
  }

  String get label {
    switch (this) {
      case SearchHitKind.subject:
        return 'Subject';
      case SearchHitKind.topic:
        return 'Topic';
      case SearchHitKind.assignment:
        return 'Assignment';
      case SearchHitKind.exam:
        return 'Exam';
      case SearchHitKind.note:
        return 'Note';
      case SearchHitKind.flashcard:
        return 'Flashcard';
    }
  }
}

/// Debounce-friendly query state.
class SearchQueryNotifier extends StateNotifier<String> {
  SearchQueryNotifier() : super('');
  void setQuery(String q) => state = q;
}

final searchQueryProvider =
    StateNotifierProvider<SearchQueryNotifier, String>(
  (ref) => SearchQueryNotifier(),
);

final searchResultsProvider =
    FutureProvider.autoDispose<List<SearchHit>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  if (query.isEmpty) return const [];

  final subjectsRepo = ref.watch(subjectsRepositoryProvider);
  final assignmentsRepo = ref.watch(assignmentsRepositoryProvider);
  final examsRepo = ref.watch(examsRepositoryProvider);
  final notesRepo = ref.watch(notesRepositoryProvider);
  final flashcardsRepo = ref.watch(flashcardsRepositoryProvider);

  // Run all searches in parallel.
  final results = await Future.wait<List<SearchHit>>([
    _searchSubjects(subjectsRepo, query),
    _searchTopics(subjectsRepo, query),
    _searchAssignments(assignmentsRepo, query),
    _searchExams(examsRepo, query),
    _searchNotes(notesRepo, query),
    _searchFlashcards(flashcardsRepo, query),
  ]);
  return results.expand((x) => x).toList(growable: false);
});

Future<List<SearchHit>> _searchSubjects(
    SubjectsRepository repo, String query) async {
  final all = await repo.getSubjects();
  return all
      .where((s) => s.name.toLowerCase().contains(query))
      .map((s) => SearchHit(
            kind: SearchHitKind.subject,
            id: s.id ?? 0,
            title: s.name,
          ))
      .toList(growable: false);
}

Future<List<SearchHit>> _searchTopics(
    SubjectsRepository repo, String query) async {
  final all = await repo.getAllTopics();
  return all
      .where((t) => t.name.toLowerCase().contains(query))
      .map((t) => SearchHit(
            kind: SearchHitKind.topic,
            id: t.id ?? 0,
            title: t.name,
            subjectId: t.subjectId,
          ))
      .toList(growable: false);
}

Future<List<SearchHit>> _searchAssignments(
    AssignmentsRepository repo, String query) async {
  final all = await repo.getAssignments();
  return all
      .where((a) =>
          a.title.toLowerCase().contains(query) ||
          (a.description?.toLowerCase().contains(query) ?? false))
      .map((a) => SearchHit(
            kind: SearchHitKind.assignment,
            id: a.id ?? 0,
            title: a.title,
            subtitle: a.dueDate == null
                ? null
                : 'Due ${a.dueDate!.year}-${a.dueDate!.month.toString().padLeft(2, '0')}-${a.dueDate!.day.toString().padLeft(2, '0')}',
            subjectId: a.subjectId,
          ))
      .toList(growable: false);
}

Future<List<SearchHit>> _searchExams(
    ExamsRepository repo, String query) async {
  final all = await repo.getExams();
  return all
      .where((e) => e.title.toLowerCase().contains(query))
      .map((e) => SearchHit(
            kind: SearchHitKind.exam,
            id: e.id ?? 0,
            title: e.title,
            subtitle:
                '${e.examDate.year}-${e.examDate.month.toString().padLeft(2, '0')}-${e.examDate.day.toString().padLeft(2, '0')}',
            subjectId: e.subjectId,
          ))
      .toList(growable: false);
}

Future<List<SearchHit>> _searchNotes(
    NotesRepository repo, String query) async {
  final all = await repo.getNotes();
  return all
      .where((n) =>
          n.title.toLowerCase().contains(query) ||
          n.body.toLowerCase().contains(query))
      .map((n) => SearchHit(
            kind: SearchHitKind.note,
            id: n.id ?? 0,
            title: n.title,
            subtitle: n.subjectId == null
                ? null
                : 'Subject #${n.subjectId}',
            subjectId: n.subjectId,
          ))
      .toList(growable: false);
}

Future<List<SearchHit>> _searchFlashcards(
    FlashcardsRepository repo, String query) async {
  // Search across all decks and all cards.
  final decks = await repo.getDecks();
  final hits = <SearchHit>[];
  for (final d in decks) {
    if (d.name.toLowerCase().contains(query)) {
      hits.add(SearchHit(
        kind: SearchHitKind.flashcard,
        id: d.id ?? 0,
        title: d.name,
        subtitle: 'Deck',
        subjectId: d.subjectId,
      ));
    }
    if (d.id == null) continue;
    final cards = await repo.getCards(d.id!);
    for (final c in cards) {
      if (c.front.toLowerCase().contains(query) ||
          c.back.toLowerCase().contains(query)) {
        hits.add(SearchHit(
          kind: SearchHitKind.flashcard,
          id: c.id ?? 0,
          title: c.front,
          subtitle: '${d.name} • card',
          subjectId: d.subjectId,
        ));
      }
    }
  }
  return hits;
}

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hits = ref.watch(searchResultsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.search)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (v) =>
                  ref.read(searchQueryProvider.notifier).setQuery(v),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          ref
                              .read(searchQueryProvider.notifier)
                              .setQuery('');
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: hits.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return AppEmptyState(
                    title: l10n.searchEmpty,
                    message: l10n.searchHint,
                    icon: Icons.search_outlined,
                  );
                }
                // Group by kind for cleaner display.
                final grouped = <SearchHitKind, List<SearchHit>>{};
                for (final h in list) {
                  grouped.putIfAbsent(h.kind, () => []).add(h);
                }
                final order = SearchHitKind.values
                    .where((k) => grouped.containsKey(k))
                    .toList();
                return ListView(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
                  children: [
                    for (final kind in order) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            16, 12, 16, 4),
                        child: Row(
                          children: [
                            Icon(kind.icon,
                                size: 16,
                                color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              kind.label,
                              style: AppTextStyles.titleSmall.copyWith(
                                color: ThemeColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      for (final h in grouped[kind]!)
                        _HitTile(hit: h),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HitTile extends StatelessWidget {
  const _HitTile({required this.hit});
  final SearchHit hit;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(hit.kind.icon),
      title: Text(hit.title),
      subtitle: hit.subtitle == null ? null : Text(hit.subtitle!),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _open(context),
    );
  }

  void _open(BuildContext context) {
    switch (hit.kind) {
      case SearchHitKind.subject:
        if (hit.subjectId != null || hit.id != 0) {
          context.push(AppRoutes.subjectDetail.replaceAll(
            ':id',
            (hit.subjectId ?? hit.id).toString(),
          ));
        }
        break;
      case SearchHitKind.topic:
        if (hit.subjectId != null) {
          context.push(AppRoutes.subjectDetail.replaceAll(
            ':id',
            hit.subjectId!.toString(),
          ));
        }
        break;
      case SearchHitKind.assignment:
        context.push(AppRoutes.assignments);
        break;
      case SearchHitKind.exam:
        context.push(AppRoutes.examPreparation.replaceAll(
          ':id',
          hit.id.toString(),
        ));
        break;
      case SearchHitKind.note:
        context.push(AppRoutes.noteDetail.replaceAll(
          ':id',
          hit.id.toString(),
        ));
        break;
      case SearchHitKind.flashcard:
        context.push(AppRoutes.flashcards);
        break;
    }
  }
}