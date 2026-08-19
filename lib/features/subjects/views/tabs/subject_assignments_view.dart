import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../../core/providers.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../assignments/widgets/assignment_card.dart';

/// Spec 03 §"Assignments tab" — filtered list of [AssignmentCard]s.
class SubjectAssignmentsView extends ConsumerWidget {
  const SubjectAssignmentsView({super.key, required this.subjectId});

  final int subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref
          .watch(assignmentsRepositoryProvider)
          .getAssignments(subjectId: subjectId),
      builder: (context, snap) {
        if (!snap.hasData) return const AppLoading();
        final items = snap.data!;
        if (items.isEmpty) {
          return AppEmptyState(
            title: context.l10n.noAssignments,
            message: 'Assignments linked to this subject will appear here',
            icon: Icons.assignment_outlined,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, i) => const SizedBox(height: 8),
          itemBuilder: (_, i) => AssignmentCard(assignment: items[i]),
        );
      },
    );
  }
}