import 'dart:math' as math;
import '../../../transactions/domain/entities/transaction.dart';
import '../../../budget/domain/entities/budget.dart';
import '../../../goals/domain/entities/financial_goal.dart';
import '../entities/anomaly.dart';

/// Service for calculating the user's financial health score.
class HealthCalculator {
  /// Calculates overall financial health score (0 - 100) using weighted sub-scores.
  double calculateHealthScore({
    required double savingsRatioScore,        // 0 - 100
    required double budgetAdherenceScore,     // 0 - 100
    required double spendingStabilityScore,   // 0 - 100
    required double anomalyFrequencyScore,    // 0 - 100
    required double goalProgressScore,        // 0 - 100
  }) {
    final score = (savingsRatioScore * 0.30) +
        (budgetAdherenceScore * 0.25) +
        (spendingStabilityScore * 0.15) +
        (anomalyFrequencyScore * 0.15) +
        (goalProgressScore * 0.15);

    return double.parse(score.clamp(0.0, 100.0).toStringAsFixed(2));
  }

  /// Evaluates lists of [transactions], [budgets], [goals], and [anomalies]
  /// to compute raw scores and output a final financial health score.
  double calculateHealthScoreFromData({
    required List<Transaction> transactions,
    required List<Budget> budgets,
    required List<FinancialGoal> goals,
    required List<Anomaly> anomalies,
    required double initialBalance,
  }) {
    // 1. Savings Ratio Score (30%)
    double savingsRatioScore = 100.0;
    if (initialBalance > 0) {
      final totalSpent = transactions.fold<double>(0.0, (sum, tx) => sum + tx.amount);
      final remainingBalance = initialBalance - totalSpent;
      final savingsRatio = remainingBalance / initialBalance;

      if (savingsRatio < 0) {
        savingsRatioScore = 0.0;
      } else {
        // Ideal savings ratio is 30% (0.30). Ratio of 0.30 or higher gets 100 points.
        savingsRatioScore = (savingsRatio / 0.30).clamp(0.0, 1.0) * 100;
      }
    }

    // 2. Budget Adherence Score (25%)
    double budgetAdherenceScore = 100.0;
    if (budgets.isNotEmpty) {
      double totalAdherence = 0.0;
      for (final budget in budgets) {
        if (budget.spentAmount <= budget.monthlyLimit) {
          totalAdherence += 1.0;
        } else {
          // Decreases as category spending exceeds limit
          final excessRatio = (budget.spentAmount - budget.monthlyLimit) / budget.monthlyLimit;
          totalAdherence += (1.0 - excessRatio).clamp(0.0, 1.0);
        }
      }
      budgetAdherenceScore = (totalAdherence / budgets.length) * 100;
    }

    // 3. Spending Stability Score (15%)
    double spendingStabilityScore = 100.0;
    if (transactions.length > 1) {
      final totalAmount = transactions.fold<double>(0.0, (sum, tx) => sum + tx.amount);
      final mean = totalAmount / transactions.length;

      double varianceSum = 0.0;
      for (final tx in transactions) {
        varianceSum += math.pow(tx.amount - mean, 2);
      }
      final stdDev = math.sqrt(varianceSum / transactions.length);

      if (mean > 0) {
        final coeffOfVariation = stdDev / mean;
        // Higher variation = less stable. Let's say CV <= 0.5 is perfectly stable (100 points)
        // and decreases as CV increases
        spendingStabilityScore = (1.0 - (coeffOfVariation - 0.5).clamp(0.0, 1.0)) * 100;
      }
    }

    // 4. Anomaly Frequency Score (15%)
    // More anomalies = lower score. 0 anomalies = 100. 5+ anomalies = 0.
    final anomalyFrequencyScore = (1.0 - (anomalies.length / 5).clamp(0.0, 1.0)) * 100;

    // 5. Goal Progress Score (15%)
    double goalProgressScore = 100.0;
    if (goals.isNotEmpty) {
      double totalProgress = 0.0;
      for (final goal in goals) {
        if (goal.targetAmount > 0) {
          totalProgress += (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
        }
      }
      goalProgressScore = (totalProgress / goals.length) * 100;
    }

    return calculateHealthScore(
      savingsRatioScore: savingsRatioScore,
      budgetAdherenceScore: budgetAdherenceScore,
      spendingStabilityScore: spendingStabilityScore,
      anomalyFrequencyScore: anomalyFrequencyScore,
      goalProgressScore: goalProgressScore,
    );
  }
}
