import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/utils/dashboard_metrics.dart';
import '../../../shared/utils/demo_data_service.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/expense_chart_widget.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/goal_progress_widget.dart';
import '../../../shared/widgets/health_score_widget.dart';
import '../../../shared/widgets/insight_card.dart';
import '../../../shared/widgets/transaction_tile.dart';
import '../../ai/presentation/providers/ai_provider.dart';
import '../../goals/presentation/providers/goal_provider.dart';
import '../../transactions/presentation/providers/transaction_provider.dart';
import '../../wallet/presentation/providers/wallet_provider.dart';
import '../../wallet/presentation/widgets/wallet_setup_dialog.dart';

/// Dashboard tab showing financial overview and AI insights.
class DashboardTab extends ConsumerStatefulWidget {
  const DashboardTab({super.key});

  @override
  ConsumerState<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<DashboardTab> {
  bool _hasShownWalletDialog = false;

  Future<void> _loadDemoData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Demo Data'),
        content: const Text('This will generate 90 days of realistic financial data. Existing data will be preserved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Load Demo Data'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final service = DemoDataService(ref);
      service.seedAllData();

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo data loaded successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final goals = ref.watch(goalProvider);
    final healthScore = ref.watch(healthScoreProvider);
    final insights = ref.watch(insightsProvider);
    final wallet = ref.watch(walletProvider);

    // Show wallet setup dialog if no wallet exists (only once)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (wallet == null && !_hasShownWalletDialog && context.mounted) {
        setState(() => _hasShownWalletDialog = true);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const WalletSetupDialog(),
        );
      }
    });

    final monthlySpending = DashboardMetrics.monthlySpending(transactions);
    final initialBalance = wallet?.initialBalance ?? 0.0;
    final remainingBalance = DashboardMetrics.remainingBalance(initialBalance, transactions);
    final savingsRate = DashboardMetrics.savingsRate(initialBalance, remainingBalance);
    final categoryTotals =
        DashboardMetrics.categoryTotalsForMonth(transactions);
    final trendValues = DashboardMetrics.monthlyTrend(transactions);
    final trendLabels = _monthLabels(trendValues.length);

    final recentTransactions = [...transactions]
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        if (transactions.isEmpty) ...[
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.dataset_rounded,
                  size: 48,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 16),
                Text(
                  'Start with Demo Data',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Load 90 days of realistic financial data to explore all features.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _loadDemoData(context, ref),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Load Demo Data'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        _SummaryCards(
          remainingBalance: remainingBalance,
          initialBalance: initialBalance,
          monthlySpending: monthlySpending,
          savingsRate: savingsRate,
        ),
        const SizedBox(height: 16),
        HealthScoreWidget(score: healthScore),
        const SizedBox(height: 16),
        if (goals.isNotEmpty) ...[
          Text(
            'Goal Progress',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 10),
          ...goals.take(2).map(
                (goal) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GoalProgressWidget(goal: goal, compact: true),
                ),
              ),
          const SizedBox(height: 6),
        ],
        const SizedBox(height: 10),
        ExpenseChartWidget(categoryTotals: categoryTotals),
        const SizedBox(height: 16),
        MonthlyTrendChart(
          monthlyValues: trendValues,
          labels: trendLabels,
        ),
        const SizedBox(height: 16),
        Text(
          'Recent Transactions',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: recentTransactions.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.receipt_long_outlined,
                  title: 'No transactions yet',
                  subtitle: 'Add your first transaction to see activity here.',
                )
              : Column(
                  children: recentTransactions
                      .take(5)
                      .map((tx) => TransactionTile(transaction: tx))
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        Text(
          'AI Insights',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        if (insights.isEmpty)
          const EmptyStateWidget(
            icon: Icons.auto_awesome_outlined,
            title: 'No insights yet',
            subtitle: 'Add transactions to unlock AI-powered insights.',
          )
        else
          ...insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InsightCard(insight: insight),
            ),
          ),
      ],
    );
  }

  List<String> _monthLabels(int count) {
    final now = DateTime.now();
    return List.generate(count, (index) {
      final monthOffset = count - 1 - index;
      final date = DateTime(now.year, now.month - monthOffset);
      return DateFormat('MMM').format(date);
    });
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({
    required this.remainingBalance,
    required this.initialBalance,
    required this.monthlySpending,
    required this.savingsRate,
  });

  final double remainingBalance;
  final double initialBalance;
  final double monthlySpending;
  final double savingsRate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Remaining Balance',
                value: AppFormatters.currency.format(remainingBalance),
                icon: Icons.account_balance_wallet_rounded,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'Initial Balance',
                value: AppFormatters.currency.format(initialBalance),
                icon: Icons.savings_rounded,
                gradient: const LinearGradient(
                  colors: [AppColors.secondary, Color(0xFF0891B2)],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Monthly Spending',
                value: AppFormatters.currency.format(monthlySpending),
                icon: Icons.trending_down_rounded,
                gradient: const LinearGradient(
                  colors: [AppColors.warning, Color(0xFFD97706)],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'Savings Rate',
                value: '${savingsRate.toStringAsFixed(1)}%',
                icon: Icons.percent_rounded,
                gradient: const LinearGradient(
                  colors: [AppColors.accent, Color(0xFF059669)],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  final String label;
  final String value;
  final IconData icon;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      gradient: gradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 22),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
