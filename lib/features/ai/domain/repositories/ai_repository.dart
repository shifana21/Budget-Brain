import '../entities/anomaly.dart';
import '../entities/chat_message.dart';
import '../entities/insight.dart';

/// Contract defining AI analysis and chat operations.
abstract class AIRepository {
  /// Predicts future monthly expenses by category.
  ///
  /// Returns a map of category names to predicted expense values.
  Future<Map<String, double>> predictExpenses();

  /// Detects abnormal transaction behaviors/anomalies.
  Future<List<Anomaly>> detectAnomalies();

  /// Analyzes overall financial health and returns a summary description.
  Future<String> analyzeFinancialHealth();

  /// Generates actionable financial insights.
  Future<List<Insight>> generateInsights();

  /// Submits a query to the AI assistant chatbot.
  ///
  /// Returns the assistant's reply [ChatMessage].
  Future<ChatMessage> processChatQuery(String query);
}
