import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../models/profile.dart';
import '../view_models/profile_view_model.dart';

class ProfilesView extends ConsumerStatefulWidget {
  const ProfilesView({super.key});

  @override
  ConsumerState<ProfilesView> createState() => _ProfilesViewState();
}

class _ProfilesViewState extends ConsumerState<ProfilesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(profileViewModelProvider.notifier).bootstrap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(profileViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Class / Semester')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-profiles',
        onPressed: () => _editProfile(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.profiles.isEmpty
              ? const AppEmptyState(
                  title: 'No profiles yet',
                  message:
                      'Add a class or batch so we can group your semesters and subjects',
                  icon: Icons.school_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.profiles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final p = state.profiles[i];
                    final isActive = state.active?.id == p.id;
                    return AppCard(
                      onTap: () async {
                        await ref
                            .read(profileViewModelProvider.notifier)
                            .setActive(p);
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.school_rounded,
                                color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(p.name,
                                          style: AppTextStyles.titleMedium),
                                    ),
                                    if (isActive)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text('Active',
                                            style: TextStyle(
                                              color: AppColors.textOnPrimary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            )),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  [
                                    p.level.en,
                                    if (p.classLabel != null) p.classLabel!,
                                    if (p.institution != null)
                                      p.institution!,
                                  ].join(' · '),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: ThemeColors.textSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _editProfile(context, p),
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: l10n.edit,
                          ),
                          IconButton(
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete profile?'),
                                  content: const Text(
                                      'Semesters and subjects under this profile will remain but lose their association.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                await ref
                                    .read(profileViewModelProvider.notifier)
                                    .deleteProfile(p.id!);
                              }
                            },
                            icon: const Icon(Icons.delete_outline),
                            tooltip: l10n.delete,
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _editProfile(BuildContext context, Profile? existing) async {
    final name = TextEditingController(text: existing?.name ?? '');
    final instCtl =
        TextEditingController(text: existing?.institution ?? '');
    ProfileLevel level = existing?.level ?? ProfileLevel.school;
    String? classLabel = existing?.classLabel;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setSt) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing == null ? 'New profile' : 'Edit profile',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(
                      labelText: 'Profile name',
                      hintText: 'e.g. SSC 2026',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ProfileLevel>(
                    value: level,
                    decoration:
                        const InputDecoration(labelText: 'Education level'),
                    items: ProfileLevel.values
                        .map((l) => DropdownMenuItem(
                              value: l,
                              child: Text(l.en),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setSt(() {
                          level = v;
                          // Reset class label if it isn't valid for new level.
                          if (classLabel != null &&
                              !v.classOptions.contains(classLabel)) {
                            classLabel = null;
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: classLabel,
                    decoration:
                        const InputDecoration(labelText: 'Class / Year'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Select...'),
                      ),
                      ...level.classOptions.map((o) => DropdownMenuItem(
                            value: o,
                            child: Text(o),
                          )),
                    ],
                    onChanged: (v) => setSt(() => classLabel = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: instCtl,
                    decoration: const InputDecoration(
                      labelText: 'Institution (optional)',
                      hintText: 'e.g. Rajuk Uttara Model College',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (name.text.trim().isEmpty) return;
                            final p = Profile(
                              id: existing?.id,
                              name: name.text.trim(),
                              level: level,
                              classLabel: classLabel,
                              institution: instCtl.text.trim().isEmpty
                                  ? null
                                  : instCtl.text.trim(),
                              createdAt: existing?.createdAt ?? DateTime.now(),
                            );
                            if (existing == null) {
                              await ref
                                  .read(profileViewModelProvider.notifier)
                                  .addProfile(p);
                            } else {
                              await ref
                                  .read(profileViewModelProvider.notifier)
                                  .updateProfile(p);
                            }
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                          child: Text(existing == null ? 'Create' : 'Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
