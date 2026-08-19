import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/theme_colors.dart';

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.color = AppColors.primary,
    this.backgroundColor,
    this.showLabel = false,
  });

  final double value; // 0..1
  final double height;
  final Color color;
  final Color? backgroundColor;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.surfaceVariant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: height,
            backgroundColor: bg,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            '${(clamped * 100).round()}%',
            style: TextStyle(
              fontSize: 12,
              color: ThemeColors.textSecondary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}