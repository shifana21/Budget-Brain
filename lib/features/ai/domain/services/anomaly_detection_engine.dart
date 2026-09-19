import 'dart:math' as math;
import '../../../transactions/domain/entities/transaction.dart';
import '../entities/anomaly.dart';

/// Service for detecting unusual expenses using statistical Z-scores.
class AnomalyDetectionEngine {
  /// Analyzes the list of [transactions] and returns detected anomalies.
  List<Anomaly> detectAnomalies(List<Transaction> transactions) {
    if (transactions.isEmpty) return [];

    // Calculate Mean
    final totalAmount = transactions.fold<double>(0.0, (sum, tx) => sum + tx.amount);
    final mean = totalAmount / transactions.length;

    // Calculate Standard Deviation
    double varianceSum = 0.0;
    for (final tx in transactions) {
      varianceSum += math.pow(tx.amount - mean, 2);
    }
    final stdDev = math.sqrt(varianceSum / transactions.length);

    final List<Anomaly> anomalies = [];

    for (final tx in transactions) {
      double zScore = 0.0;
      if (stdDev > 0 && tx.amount > mean) {
        zScore = (tx.amount - mean) / stdDev;
      }

      String riskLevel;
      if (zScore >= 2.0) {
        riskLevel = 'HIGH';
      } else if (zScore >= 1.0) {
        riskLevel = 'MEDIUM';
      } else {
        riskLevel = 'LOW';
      }

      // Only flag as anomalies if they are MEDIUM or HIGH risk (Z >= 1.0)
      if (riskLevel == 'MEDIUM' || riskLevel == 'HIGH') {
        anomalies.add(Anomaly(
          transactionId: tx.id,
          riskLevel: riskLevel,
          message: 'Unusual transaction detected: spent ₹${tx.amount.toStringAsFixed(2)} at ${tx.merchant}. (Z-score: ${zScore.toStringAsFixed(2)})',
        ));
      }
    }

    return anomalies;
  }
}
