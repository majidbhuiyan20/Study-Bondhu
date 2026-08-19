import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/quick_add_sheet.dart';
import '../view_models/exams_view_model.dart';
import '../widgets/exam_card.dart';

class ExamsView extends ConsumerStatefulWidget {
  const ExamsView({super.key});

  @override
  ConsumerState<ExamsView> createState() => _ExamsViewState();
}

class _ExamsViewState extends ConsumerState<ExamsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(examsViewModelProvider.notifier).bootstrap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(examsViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.exams)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-exams',
        onPressed: () => QuickAddSheet.show(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addExam),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: state.isLoading
          ? const AppLoading()
          : state.exams.isEmpty
              ? AppEmptyState(
                  title: l10n.noExams,
                  message: l10n.examsHint,
                  icon: Icons.event_note_outlined,
                  actionLabel: l10n.addExam,
                  onAction: () =>
                      context.push(AppRoutes.examAdd),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.exams.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (_, i) => ExamCard(exam: state.exams[i]),
                ),
    );
  }
}
