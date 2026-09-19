/// Represents an anomaly detected in the user's transaction patterns.
class Anomaly {
  final String transactionId;
  final String riskLevel;
  final String message;

  const Anomaly({
    required this.transactionId,
    required this.riskLevel,
    required this.message,
  });
}
