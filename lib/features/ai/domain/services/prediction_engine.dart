import '../../../transactions/domain/entities/transaction.dart';

/// Service for predicting future spending using moving averages and weighted trend analysis.
class PredictionEngine {
  /// Predicts the next 30-day spending for each category based on historical [transactions].
  ///
  /// Optionally takes [relativeTo] date (defaults to DateTime.now()).
  Map<String, double> predictCategoryExpenses(
    List<Transaction> transactions, {
    DateTime? relativeTo,
  }) {
    final now = relativeTo ?? DateTime.now();
    final Map<String, List<Transaction>> grouped = {};

    // Group transactions by category
    for (final tx in transactions) {
      grouped.putIfAbsent(tx.category, () => []).add(tx);
    }

    final Map<String, double> predictions = {};

    grouped.forEach((category, list) {
      double totalWeightedAmount = 0.0;
      double totalWeights = 0.0;

      for (final tx in list) {
        final ageInDays = now.difference(tx.date).inDays;
        if (ageInDays < 0) continue; // Skip future transactions

        // Weighted trend analysis: recent transactions carry more weight
        double weight = 0.1;
        if (ageInDays <= 10) {
          weight = 1.5;
        } else if (ageInDays <= 20) {
          weight = 1.0;
        } else if (ageInDays <= 30) {
          weight = 0.5;
        } else {
          weight = 0.2;
        }

        totalWeightedAmount += tx.amount * weight;
        totalWeights += weight;
      }

      if (totalWeights > 0) {
        // Calculate the base weighted average transaction value
        final weightedAverageVal = totalWeightedAmount / totalWeights;

        // Calculate transaction frequency (average transactions per day over the span of transactions)
        // Find the earliest transaction date to define the historical span
        final earliestDate = list.fold<DateTime>(
          now,
          (prev, element) => element.date.isBefore(prev) ? element.date : prev,
        );
        final spanInDays = now.difference(earliestDate).inDays;
        final activeDays = spanInDays <= 0 ? 1 : spanInDays;

        final txCount = list.length;
        final dailyTxFrequency = txCount / activeDays;

        // Predict next 30 days: (Average Value) * (Daily Frequency) * 30 days
        final predicted30Days = weightedAverageVal * dailyTxFrequency * 30;
        predictions[category] = double.parse(predicted30Days.toStringAsFixed(2));
      } else {
        predictions[category] = 0.0;
      }
    });

    return predictions;
  }

  /// Predicts the total next 30-day spending across all categories.
  double predictTotalExpenses(List<Transaction> transactions, {DateTime? relativeTo}) {
    final predictions = predictCategoryExpenses(transactions, relativeTo: relativeTo);
    final total = predictions.values.fold(0.0, (sum, val) => sum + val);
    return double.parse(total.toStringAsFixed(2));
  }
}
