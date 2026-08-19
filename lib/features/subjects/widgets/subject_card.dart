import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla,AppLocalizationsCamelCase;
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../models/subject.dart';
import '../view_models/subjects_view_model.dart';
import 'edit_subject_sheet.dart';

/// Subject row used in the subjects list (spec 02).
///
/// Long-press / overflow menu offers:
///   - Edit subject (opens [EditSubjectSheet])
///   - Change semester
///   - Delete subject (with cascade confirmation)
class SubjectCard extends ConsumerWidget {
  const SubjectCard({super.key, required this.subject, this.onTap});

  final Subject subject;
  final VoidCallback? onTap;

  // Cache: spec asks for O(1) lookup and avoiding hex re-decode.
  // We memoize per instance via a small static map keyed by id.
  static final Map<int, Color> _colorCache = {};
  static final Map<int, IconData> _iconCache = {};

  Color get _color {
    final key = subject.id ?? subject.name.hashCode;
    final cached = _colorCache[key];
    if (cached != null) return cached;
    final hex = subject.color.replaceAll('#', '');
    final c = Color(int.parse('FF$hex', radix: 16));
    _colorCache[key] = c;
    return c;
  }

  IconData _subjectIcon() {
    final key = subject.id ?? subject.name.hashCode;
    final cached = _iconCache[key];
    if (cached != null) return cached;
    final name = subject.name.toLowerCase();
    IconData icon = Icons.menu_book_rounded;
    if (name.contains('math') || name.contains('গণিত')) {
      icon = Icons.calculate_rounded;
    } else if (name.contains('phys') || name.contains('পদার্থ')) {
      icon = Icons.science_rounded;
    } else if (name.contains('chem') || name.contains('রসায়ন')) {
      icon = Icons.biotech_rounded;
    } else if (name.contains('bio') || name.contains('জীব')) {
      icon = Icons.eco_rounded;
    } else if (name.contains('eng') || name.contains('ইংরেজি')) {
      icon = Icons.translate_rounded;
    } else if (name.contains('bangla') || name.contains('বাংলা')) {
      icon = Icons.menu_book_rounded;
    } else if (name.contains('hist') || name.contains('ইতিহাস')) {
      icon = Icons.history_edu_rounded;
    } else if (name.contains('ict') || name.contains('program')) {
      icon = Icons.code_rounded;
    }
    _iconCache[key] = icon;
    return icon;
  }

  String _creditLabel(BuildContext context) {
    final cr = subject.credit!;
    final isBangla = context.l10n.isBangla;
    final n = cr == cr.roundToDouble() ? cr.toInt().toString() : cr.toString();
    return isBangla ? '$n ক্রি' : '$n ${context.l10n.creditShort}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBangla = context.l10n.isBangla;
    final l10n = context.l10n;
    return AppCard(
      onTap: onTap,
      onLongPress: () => _showMenu(context, ref),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_subjectIcon(), color: _color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: AppTextStyles.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subject.code != null && subject.code!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    isBangla && subject.teacher != null
                        ? '${subject.code} • ${subject.teacher}'
                        : subject.code!,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (subject.credit != null)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: ThemeColors.surfaceAlt(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _creditLabel(context),
                style: AppTextStyles.bodySmall.copyWith(
                  color: ThemeColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 4),
          // Overflow menu (Edit / Change semester / Delete)
          PopupMenuButton<String>(
            tooltip: l10n.edit,
            icon: Icon(Icons.more_vert,
                color: ThemeColors.textSecondary(context), size: 20),
            onSelected: (v) async {
              switch (v) {
                case 'edit':
                  await EditSubjectSheet.show(context, existing: subject);
                  break;
                case 'change_sem':
                  // Handled in subjects_view through context.push
                  break;
                case 'delete':
                  await _confirmDelete(context, ref);
                  break;
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  const Icon(Icons.edit_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(l10n.edit),
                ]),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  const Icon(Icons.delete_outline,
                      size: 18, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(l10n.delete,
                      style: const TextStyle(color: Colors.red)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final l10n = ctx.l10n;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(subject.name,
                      style: AppTextStyles.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(l10n.editSubject),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await EditSubjectSheet.show(context, existing: subject);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(l10n.deleteSubject,
                      style: const TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _confirmDelete(context, ref);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${l10n.deleteSubject} "${subject.name}"?'),
        content: Text(l10n.thisActionCannotBeUndone),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref
          .read(subjectsViewModelProvider.notifier)
          .deleteSubject(subject.id!);
    }
  }
}