import 'package:flutter/material.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla;
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../models/subject.dart';
import '../models/syllabus_item.dart';

/// The header card on Subject Details (spec 03 §"Header").
///
/// Layout:
///   ┌────────────────────────────────────────┐
///   │ [icon]  Operating System               │
///   │         CSE-321 • 3 Credits • Mr. Karim│
///   │         ████████░░ 72% syllabus complete│
///   └────────────────────────────────────────┘
class SubjectDetailHeader extends StatelessWidget {
  const SubjectDetailHeader({
    super.key,
    required this.subject,
    required this.syllabus,
  });

  final Subject subject;
  final List<SyllabusItem> syllabus;

  double get _progress {
    if (syllabus.isEmpty) return 0.0;
    final done = syllabus.where((s) => s.isDone).length;
    return done / syllabus.length;
  }

  String _subtitle(BuildContext context) {
    final parts = <String>[];
    if (subject.code != null && subject.code!.isNotEmpty) parts.add(subject.code!);
    if (subject.credit != null) {
      final cr = subject.credit!;
      final txt = cr == cr.roundToDouble()
          ? cr.toInt().toString()
          : cr.toString();
      parts.add(context.l10n.isBangla ? '$txt ক্রে' : '$txt cr');
    }
    if (subject.teacher != null && subject.teacher!.isNotEmpty) {
      parts.add(subject.teacher!);
    }
    return parts.join(' • ');
  }

  Color get _color {
    final hex = subject.color.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pct = (_progress * 100).round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.menu_book_rounded,
                      color: _color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: AppTextStyles.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_subtitle(context).isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          _subtitle(context),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: ThemeColors.textSecondary(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (syllabus.isNotEmpty) ...[
              const SizedBox(height: 14),
              AppProgressBar(value: _progress, height: 8),
              const SizedBox(height: 4),
              Text(
                l10n.isBangla
                    ? 'সিলেবাস $pct% সম্পন্ন'
                    : '$pct% syllabus complete',
                style: AppTextStyles.bodySmall.copyWith(
                  color: ThemeColors.textSecondary(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}