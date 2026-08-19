import 'package:flutter/material.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla,AppLocalizationsCamelCase;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart' as du;

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, this.name = 'Bondhu'});
  final String name;

  String _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final l10n = context.l10n;
    if (hour < 5) return l10n.lateNight;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    if (hour < 21) return l10n.goodEvening;
    return l10n.goodNight;
  }

  String _subGreeting(BuildContext context) {
    final today = du.AppDateUtils.today;
    if (context.l10n.isBangla) {
      const months = [
        'জানুয়ারি',
        'ফেব্রুয়ারি',
        'মার্চ',
        'এপ্রিল',
        'মে',
        'জুন',
        'জুলাই',
        'আগস্ট',
        'সেপ্টেম্বর',
        'অক্টোবর',
        'নভেম্বর',
        'ডিসেম্বর'
      ];
      return 'আজ ${today.day} ${months[today.month - 1]}';
    }
    return du.AppDateUtils.formatDate(today, pattern: 'EEEE, MMM d');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDeep],
            ),
          ),
          child: const Icon(Icons.bolt_rounded,
              color: AppColors.textOnPrimary, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _subGreeting(context).toUpperCase(),
                style: AppTextStyles.label,
              ),
              const SizedBox(height: 2),
              Text(
                '${_greeting(context)}, $name',
                style: AppTextStyles.headlineMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
