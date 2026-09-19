import '../../features/transactions/domain/entities/transaction.dart';

/// Presentation-layer aggregations for dashboard display.
abstract final class DashboardMetrics {
  static double monthlySpending(List<Transaction> transactions, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    return transactions
        .where((tx) =>
            tx.date.year == reference.year && tx.date.month == reference.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  static double totalSpending(List<Transaction> transactions) {
    return transactions.fold<double>(0.0, (sum, tx) => sum + tx.amount);
  }

  static double remainingBalance(double initialBalance, List<Transaction> transactions) {
    final totalSpent = totalSpending(transactions);
    return initialBalance - totalSpent;
  }

  static double savingsRate(double initialBalance, double remainingBalance) {
    if (initialBalance <= 0) return 0.0;
    return (remainingBalance / initialBalance) * 100;
  }

  @Deprecated('Use remainingBalance with wallet initial balance instead')
  static double estimatedBalance(List<Transaction> transactions) {
    final totalSpent = transactions.fold<double>(0.0, (sum, tx) => sum + tx.amount);
    final baselineIncome = totalSpent > 0 ? totalSpent * 1.3 : 3000.0;
    return baselineIncome - totalSpent;
  }

  static Map<String, double> categoryTotalsForMonth(
    List<Transaction> transactions, {
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final totals = <String, double>{};

    for (final tx in transactions) {
      if (tx.date.year == reference.year && tx.date.month == reference.month) {
        totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
      }
    }

    return totals;
  }

  static List<double> monthlyTrend(List<Transaction> transactions, {int months = 6}) {
    final now = DateTime.now();
    return List.generate(months, (index) {
      final monthOffset = months - 1 - index;
      final target = DateTime(now.year, now.month - monthOffset);
      return transactions
          .where((tx) => tx.date.year == target.year && tx.date.month == target.month)
          .fold(0.0, (sum, tx) => sum + tx.amount);
    });
  }
}
