import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/utils/dashboard_metrics.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/insight_card.dart';
import '../../ai/domain/entities/anomaly.dart';
import '../../ai/presentation/providers/ai_provider.dart';
import '../../transactions/presentation/providers/transaction_provider.dart';

/// Analytics tab powered by AI predictions and behavioral insights.
class AnalyticsTab extends ConsumerWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predictions = ref.watch(predictionsProvider);
    final anomalies = ref.watch(anomaliesProvider);
    final insights = ref.watch(insightsProvider);
    final transactions = ref.watch(transactionProvider);
    final sortedPredictions = predictions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final currentMonth = DashboardMetrics.monthlySpending(transactions);
    final previousMonth = DashboardMetrics.monthlySpending(
      transactions,
      now: DateTime(DateTime.now().year, DateTime.now().month - 1),
    );
    final predictedTotal =
        predictions.values.fold(0.0, (sum, value) => sum + value);
    final trendValues = DashboardMetrics.monthlyTrend(transactions, months: 6);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        _PredictedSpendingChart(
          predictions: sortedPredictions,
          predictedTotal: predictedTotal,
        ),
        const SizedBox(height: 16),
        Text(
          'Category Forecasts',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        if (predictions.isEmpty)
          const EmptyStateWidget(
            icon: Icons.insights_outlined,
            title: 'No forecasts yet',
            subtitle: 'Add transactions to generate spending predictions.',
          )
        else
          ...sortedPredictions.take(6).map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ForecastCard(
                    category: entry.key,
                    amount: entry.value,
                  ),
                ),
              ),
        const SizedBox(height: 16),
        Text(
          'Anomaly Alerts',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        if (anomalies.isEmpty)
          GlassCard(
            child: Row(
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.accent.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No anomalies detected. Your spending looks normal.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          )
        else
          ...anomalies.map(
            (anomaly) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AnomalyCard(anomaly: anomaly),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'Behavioral Insights',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        if (insights.isEmpty)
          const EmptyStateWidget(
            icon: Icons.psychology_outlined,
            title: 'No behavioral insights',
            subtitle: 'More transaction history unlocks deeper analysis.',
          )
        else
          ...insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InsightCard(insight: insight),
            ),
          ),
        const SizedBox(height: 16),
        _SpendingTrendAnalysis(values: trendValues),
        const SizedBox(height: 16),
        _MonthlyComparison(
          currentMonth: currentMonth,
          previousMonth: previousMonth,
          predictedNext: predictedTotal,
        ),
      ],
    );
  }
}

class _PredictedSpendingChart extends StatelessWidget {
  const _PredictedSpendingChart({
    required this.predictions,
    required this.predictedTotal,
  });

  final List<MapEntry<String, double>> predictions;
  final double predictedTotal;

  @override
  Widget build(BuildContext context) {
    if (predictions.isEmpty) {
      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Predicted Spending (30 days)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 24),
            const Center(child: Text('Insufficient data for predictions')),
          ],
        ),
      );
    }

    final top = predictions.take(5).toList();
    final maxY = top.fold(0.0, (max, e) => e.value > max ? e.value : max) * 1.2;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Predicted Spending (30 days)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                AppFormatters.currency.format(predictedTotal),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY <= 0 ? 100 : maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.08),
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
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= top.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            top[index].key.substring(
                              0,
                              top[index].key.length.clamp(0, 6),
                            ),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(top.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: top[index].value,
                        color: AppTheme.chartPalette[
                            index % AppTheme.chartPalette.length],
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({required this.category, required this.amount});

  final String category;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.trending_up_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  'Predicted next 30 days',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                ),
              ],
            ),
          ),
          Text(
            AppFormatters.currency.format(amount),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _AnomalyCard extends StatelessWidget {
  const _AnomalyCard({required this.anomaly});

  final Anomaly anomaly;

  Color get _riskColor {
    return switch (anomaly.riskLevel.toLowerCase()) {
      'high' => AppColors.danger,
      'medium' => AppColors.warning,
      _ => AppColors.secondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: _riskColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${anomaly.riskLevel} Risk',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _riskColor,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  anomaly.message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.4,
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

class _SpendingTrendAnalysis extends StatelessWidget {
  const _SpendingTrendAnalysis({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return GlassCard(
        child: Text(
          'Spending Trend Analysis',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      );
    }

    final change = values.last - values[values.length - 2];
    final percentChange = values[values.length - 2] > 0
        ? (change / values[values.length - 2] * 100)
        : 0.0;
    final isUp = change >= 0;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Trend Analysis',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                color: isUp ? AppColors.danger : AppColors.accent,
              ),
              const SizedBox(width: 8),
              Text(
                '${percentChange.abs().toStringAsFixed(1)}% ${isUp ? 'increase' : 'decrease'} vs last month',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isUp ? AppColors.danger : AppColors.accent,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isUp
                ? 'Your spending is trending upward. Review top categories to stay on track.'
                : 'Great job! Your spending decreased compared to last month.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyComparison extends StatelessWidget {
  const _MonthlyComparison({
    required this.currentMonth,
    required this.previousMonth,
    required this.predictedNext,
  });

  final double currentMonth;
  final double previousMonth;
  final double predictedNext;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Comparison',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          _ComparisonRow(
            label: 'This Month',
            amount: currentMonth,
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          _ComparisonRow(
            label: 'Last Month',
            amount: previousMonth,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 10),
          _ComparisonRow(
            label: 'Predicted Next 30 Days',
            amount: predictedNext,
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          AppFormatters.currency.format(amount),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
