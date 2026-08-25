import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/profile.dart';
import '../view_models/profile_view_model.dart';

/// Shows the create/edit profile bottom sheet. When [existing] is null,
/// the sheet creates a new profile (and — if [setAsActive] is true —
/// marks it active). Otherwise it updates the profile in place.
///
/// Reusable from any view that needs to manage profiles.
Future<void> showEditProfileSheet(
  BuildContext context, {
  Profile? existing,
  bool setAsActive = false,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _EditProfileSheet(
      existing: existing,
      setAsActive: setAsActive,
    ),
  );
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({this.existing, required this.setAsActive});
  final Profile? existing;
  final bool setAsActive;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _institution =
      TextEditingController(text: widget.existing?.institution ?? '');
  late ProfileLevel _level = widget.existing?.level ?? ProfileLevel.school;
  late String? _classLabel = widget.existing?.classLabel;

  @override
  void dispose() {
    _name.dispose();
    _institution.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: StatefulBuilder(
        builder: (ctx, setSt) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existing == null ? 'New profile' : 'Edit profile',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Profile name',
                  hintText: 'e.g. SSC 2026',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ProfileLevel>(
                initialValue: _level,
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
                      _level = v;
                      if (_classLabel != null &&
                          !v.classOptions.contains(_classLabel)) {
                        _classLabel = null;
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _classLabel,
                decoration:
                    const InputDecoration(labelText: 'Class / Year'),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Select...'),
                  ),
                  ..._level.classOptions.map((o) => DropdownMenuItem(
                        value: o,
                        child: Text(o),
                      )),
                ],
                onChanged: (v) => setSt(() => _classLabel = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _institution,
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                      ),
                      onPressed: () async {
                        if (_name.text.trim().isEmpty) return;
                        final p = Profile(
                          id: widget.existing?.id,
                          name: _name.text.trim(),
                          level: _level,
                          classLabel: _classLabel,
                          institution: _institution.text.trim().isEmpty
                              ? null
                              : _institution.text.trim(),
                          createdAt:
                              widget.existing?.createdAt ?? DateTime.now(),
                        );
                        if (widget.existing == null) {
                          await ref
                              .read(profileViewModelProvider.notifier)
                              .addProfile(p, setAsActive: widget.setAsActive);
                        } else {
                          await ref
                              .read(profileViewModelProvider.notifier)
                              .updateProfile(p);
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child:
                          Text(widget.existing == null ? 'Create' : 'Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}