import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../subjects/models/subject.dart';
import '../../subjects/view_models/subjects_view_model.dart';
import '../models/local_resource.dart';
import '../view_models/resources_view_model.dart';

/// Spec #27 — list of local file resources. Users paste a file path, give
/// it a title, and the path is stored. The app never copies the file, so
/// the user stays in control of their data. Tapping a row shows the path
/// so they can open it with their file manager.
class ResourcesView extends ConsumerStatefulWidget {
  const ResourcesView({super.key, this.subjectId});
  final int? subjectId;

  @override
  ConsumerState<ResourcesView> createState() => _State();
}

class _State extends ConsumerState<ResourcesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(resourcesViewModelProvider.notifier)
            .load(subjectId: widget.subjectId);
      }
    });
  }

  Future<void> _addDialog() async {
    final l10n = context.l10n;
    final isBn = l10n.isBangla;
    final subjects = ref.read(subjectsViewModelProvider).subjects;
    int? subjectId = widget.subjectId ??
        (subjects.isNotEmpty ? subjects.first.id : null);
    final title = TextEditingController();
    final path = TextEditingController();
    final mime = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: Text(isBn ? 'নতুন রিসোর্স যোগ' : 'Add resource'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.subjectId == null)
                    DropdownButtonFormField<int>(
                      initialValue: subjectId,
                      decoration: InputDecoration(
                          labelText: isBn ? 'বিষয়' : 'Subject'),
                      items: subjects
                          .map((s) => DropdownMenuItem(
                              value: s.id, child: Text(s.name)))
                          .toList(),
                      onChanged: (v) => setState(() => subjectId = v),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: title,
                    decoration: InputDecoration(
                      labelText: isBn ? 'শিরোনাম' : 'Title',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: path,
                    decoration: InputDecoration(
                      labelText: isBn ? 'ফাইলের পাথ' : 'File path',
                      hintText: '/storage/emulated/0/Download/...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: mime,
                    decoration: InputDecoration(
                      labelText: isBn
                          ? 'MIME (ঐচ্ছিক)'
                          : 'MIME type (optional)',
                      hintText: 'application/pdf',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(isBn ? 'বাতিল' : 'Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (subjectId == null ||
                      title.text.trim().isEmpty ||
                      path.text.trim().isEmpty) {
                    return;
                  }
                  await ref.read(resourcesViewModelProvider.notifier).add(
                        LocalResource(
                          subjectId: subjectId!,
                          title: title.text.trim(),
                          path: path.text.trim(),
                          mimeType: mime.text.trim().isEmpty
                              ? null
                              : mime.text.trim(),
                          createdAt: DateTime.now(),
                        ),
                      );
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx, true);
                },
                child: Text(isBn ? 'সংরক্ষণ' : 'Save'),
              ),
            ],
          ),
        );
      },
    );
    if (result == true) {
      ref
          .read(resourcesViewModelProvider.notifier)
          .load(subjectId: widget.subjectId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isBn = l10n.isBangla;
    final state = ref.watch(resourcesViewModelProvider);
    final subjects = ref.watch(subjectsViewModelProvider).subjects;
    return Scaffold(
      appBar: AppBar(
        title: Text(isBn ? 'রিসোর্স' : 'Resources'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab-resources',
        onPressed: _addDialog,
        child: const Icon(Icons.add),
      ),
      body: state.isLoading
          ? const AppLoading()
          : state.resources.isEmpty
              ? AppEmptyState(
                  title: isBn ? 'কোনো রিসোর্স নেই' : 'No resources yet',
                  message: isBn
                      ? 'PDF, ছবি বা অডিও ফাইলের পাথ যোগ করুন'
                      : 'Add a file path — PDF, image, audio',
                  icon: Icons.folder_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.resources.length,
                  separatorBuilder: (_, i) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final r = state.resources[i];
                    final subject = _subjectById(subjects, r.subjectId);
                    return AppCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(_iconForMime(r.mimeType),
                                color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(
                                  '${subject?.name ?? ''}${r.mimeType != null ? ' · ${r.mimeType}' : ''}',
                                  style: TextStyle(
                                      color: ThemeColors.textSecondary(context),
                                      fontSize: 12),
                                ),
                                Text(
                                  r.path,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: ThemeColors.textTertiary(context),
                                      fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Copy path',
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: () async {
                              final messenger =
                                  ScaffoldMessenger.of(context);
                              await Clipboard.setData(
                                  ClipboardData(text: r.path));
                              if (!mounted) return;
                              messenger.showSnackBar(
                                SnackBar(
                                    content: Text(isBn
                                        ? 'পাথ কপি হয়েছে'
                                        : 'Path copied')),
                              );
                            },
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.error),
                            onPressed: () => ref
                                .read(resourcesViewModelProvider.notifier)
                                .delete(r.id!),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  IconData _iconForMime(String? mime) {
    if (mime == null) return Icons.insert_drive_file_outlined;
    if (mime.startsWith('image/')) return Icons.image_outlined;
    if (mime.startsWith('audio/')) return Icons.audiotrack_outlined;
    if (mime.startsWith('video/')) return Icons.video_file_outlined;
    if (mime.contains('pdf')) return Icons.picture_as_pdf_outlined;
    return Icons.insert_drive_file_outlined;
  }

  Subject? _subjectById(List<Subject> subjects, int id) {
    for (final s in subjects) {
      if (s.id == id) return s;
    }
    return null;
  }
}