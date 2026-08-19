import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../study/repositories/study_repository.dart';

/// BarChart wrapper used by the analytics dashboard (spec 15).
class WeeklyChartCard extends StatelessWidget {
  const WeeklyChartCard({super.key, required this.summary});
  final List<DailyStudySummary> summary;

  @override
  Widget build(BuildContext context) {
    if (summary.isEmpty) {
      return const AppCard(
        child: SizedBox(
          height: 160,
          child: Center(child: Text('No data yet')),
        ),
      );
    }
    final maxMinutes = summary
        .map((s) => s.seconds / 60)
        .fold<double>(0, (acc, v) => v > acc ? v : acc);
    final upper = (maxMinutes < 30 ? 30 : maxMinutes * 1.2).toDouble();
    return AppCard(
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: upper,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= summary.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                        style: TextStyle(
                          color: ThemeColors.textSecondary(context),
                          fontSize: 11,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(summary.length, (i) {
              final mins = summary[i].seconds / 60;
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: mins,
                    color: AppColors.primary,
                    width: 16,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
