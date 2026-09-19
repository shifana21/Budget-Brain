import 'package:flutter_riverpod/flutter_riverpod.dart';

// Engines & Services
import '../../domain/services/prediction_engine.dart';
import '../../domain/services/anomaly_detection_engine.dart';
import '../../domain/services/behavioral_engine.dart';
import '../../domain/services/health_calculator.dart';

// Entities
import '../../../transactions/domain/entities/transaction.dart';
import '../../../budget/domain/entities/budget.dart';
import '../../../goals/domain/entities/financial_goal.dart';
import '../../domain/entities/anomaly.dart';
import '../../domain/entities/insight.dart';

// Providers dependencies
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../goals/presentation/providers/goal_provider.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';

/// Combined state class exposed by the [AIProvider].
class AIState {
  final double healthScore;
  final List<Anomaly> anomalies;
  final Map<String, double> predictions;
  final List<Insight> insights;

  const AIState({
    required this.healthScore,
    required this.anomalies,
    required this.predictions,
    required this.insights,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIState &&
          runtimeType == other.runtimeType &&
          healthScore == other.healthScore &&
          anomalies.length == other.anomalies.length &&
          predictions.length == other.predictions.length &&
          insights.length == other.insights.length;

  @override
  int get hashCode =>
      healthScore.hashCode ^
      anomalies.length.hashCode ^
      predictions.length.hashCode ^
      insights.length.hashCode;
}

/// State notifier that reactively recalculates AI metrics upon data updates.
class AINotifier extends StateNotifier<AIState> {
  AINotifier(
    List<Transaction> transactions,
    List<Budget> budgets,
    List<FinancialGoal> goals,
    double initialBalance,
  ) : super(const AIState(healthScore: 100.0, anomalies: [], predictions: {}, insights: [])) {
    recalculate(transactions, budgets, goals, initialBalance);
  }

  /// Calculates predictions, anomalies, behavior, health score, and insights.
  void recalculate(
    List<Transaction> transactions,
    List<Budget> budgets,
    List<FinancialGoal> goals,
    double initialBalance,
  ) {
    final predictionEngine = PredictionEngine();
    final anomalyDetectionEngine = AnomalyDetectionEngine();
    final behavioralEngine = BehavioralEngine();
    final healthCalculator = HealthCalculator();

    final predictions = predictionEngine.predictCategoryExpenses(transactions);
    final anomalies = anomalyDetectionEngine.detectAnomalies(transactions);
    final insights = behavioralEngine.analyzeBehavior(transactions);

    final healthScore = healthCalculator.calculateHealthScoreFromData(
      transactions: transactions,
      budgets: budgets,
      goals: goals,
      anomalies: anomalies,
      initialBalance: initialBalance,
    );

    state = AIState(
      healthScore: healthScore,
      anomalies: anomalies,
      predictions: predictions,
      insights: insights,
    );
  }
}

/// Provider for [AINotifier] that reactively updates state whenever transactions, budgets, or goals change.
final aiProvider = StateNotifierProvider<AINotifier, AIState>((ref) {
  final transactions = ref.watch(transactionProvider);
  final budgets = ref.watch(budgetProvider);
  final goals = ref.watch(goalProvider);
  final wallet = ref.watch(walletProvider);

  return AINotifier(transactions, budgets, goals, wallet?.initialBalance ?? 0.0);
});

/// Selectors for specific AI state properties to prevent unnecessary rebuilds
final healthScoreProvider = Provider<double>((ref) {
  return ref.watch(aiProvider).healthScore;
});

final anomaliesProvider = Provider<List<Anomaly>>((ref) {
  return ref.watch(aiProvider).anomalies;
});

final predictionsProvider = Provider<Map<String, double>>((ref) {
  return ref.watch(aiProvider).predictions;
});

final insightsProvider = Provider<List<Insight>>((ref) {
  return ref.watch(aiProvider).insights;
});
