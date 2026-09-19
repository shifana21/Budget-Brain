import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'glass_card.dart';

/// Pie chart for category spending breakdown.
class ExpenseChartWidget extends StatelessWidget {
  const ExpenseChartWidget({
    super.key,
    required this.categoryTotals,
    this.title = 'Spending by Category',
    this.height = 220,
  });

  final Map<String, double> categoryTotals;
  final String title;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return GlassCard(
        child: SizedBox(
          height: height,
          child: Center(
            child: Text(
              'No spending data this month',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ),
        ),
      );
    }

    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold(0.0, (sum, e) => sum + e.value);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: height,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 36,
                      sections: List.generate(entries.length, (index) {
                        final entry = entries[index];
                        final percentage =
                            total > 0 ? (entry.value / total * 100) : 0.0;
                        final color = AppTheme.chartPalette[
                            index % AppTheme.chartPalette.length];

                        return PieChartSectionData(
                          value: entry.value,
                          title: '${percentage.toStringAsFixed(0)}%',
                          color: color,
                          radius: 52,
                          titleStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ListView.separated(
                    itemCount: entries.length.clamp(0, 5),
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final color = AppTheme.chartPalette[
                          index % AppTheme.chartPalette.length];
                      return Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Line chart for monthly spending trend.
class MonthlyTrendChart extends StatelessWidget {
  const MonthlyTrendChart({
    super.key,
    required this.monthlyValues,
    this.labels,
    this.height = 200,
  });

  final List<double> monthlyValues;
  final List<String>? labels;
  final double height;

  @override
  Widget build(BuildContext context) {
    final maxY = monthlyValues.isEmpty
        ? 100.0
        : monthlyValues.reduce((a, b) => a > b ? a : b) * 1.2;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Trend',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: height,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY <= 0 ? 100 : maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.08),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        '₹${value.toInt()}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (labels != null &&
                            index >= 0 &&
                            index < labels!.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels![index],
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      monthlyValues.length,
                      (i) => FlSpot(i.toDouble(), monthlyValues[i]),
                    ),
                    isCurved: true,
                    color: AppColors.secondary,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.secondary.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
