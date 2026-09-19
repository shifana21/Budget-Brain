import 'package:flutter_test/flutter_test.dart';

// Services
import 'package:budget_brain/features/ai/domain/services/prediction_engine.dart';
import 'package:budget_brain/features/ai/domain/services/anomaly_detection_engine.dart';
import 'package:budget_brain/features/ai/domain/services/behavioral_engine.dart';
import 'package:budget_brain/features/ai/domain/services/health_calculator.dart';
import 'package:budget_brain/features/ai/domain/services/advisor_chat_engine.dart';

// Entities
import 'package:budget_brain/features/transactions/domain/entities/transaction.dart';
import 'package:budget_brain/features/budget/domain/entities/budget.dart';
import 'package:budget_brain/features/goals/domain/entities/financial_goal.dart';

void main() {
  group('AI Financial Engine Tests', () {
    late DateTime now;
    late List<Transaction> sampleTransactions;

    setUp(() {
      now = DateTime(2026, 6, 20);

      sampleTransactions = [
        Transaction(
          id: '1',
          amount: 50.0,
          merchant: 'Grocery Store A',
          category: 'Food',
          date: now.subtract(const Duration(days: 5)),
          paymentMethod: 'Debit Card',
          isRecurring: false,
        ),
        Transaction(
          id: '2',
          amount: 100.0,
          merchant: 'Restaurant B',
          category: 'Food',
          date: now.subtract(const Duration(days: 15)),
          paymentMethod: 'Credit Card',
          isRecurring: false,
        ),
        Transaction(
          id: '3',
          amount: 1200.0,
          merchant: 'Apartment Landlord',
          category: 'Rent',
          date: now.subtract(const Duration(days: 1)),
          paymentMethod: 'Bank Transfer',
          isRecurring: true,
        ),
        Transaction(
          id: '4',
          amount: 80.0,
          merchant: 'Power Utility',
          category: 'Utilities',
          date: now.subtract(const Duration(days: 25)),
          paymentMethod: 'Auto-Pay',
          isRecurring: true,
        ),
      ];
    });

    test('PredictionEngine: category and total expenses forecasting accuracy', () {
      final engine = PredictionEngine();

      final predictions = engine.predictCategoryExpenses(sampleTransactions, relativeTo: now);
      expect(predictions, isNotEmpty);
      expect(predictions.containsKey('Food'), isTrue);
      expect(predictions.containsKey('Rent'), isTrue);
      expect(predictions.containsKey('Utilities'), isTrue);

      final total = engine.predictTotalExpenses(sampleTransactions, relativeTo: now);
      final manualSum = predictions.values.reduce((value, element) => value + element);
      expect(total, closeTo(manualSum, 0.01));
    });

    test('AnomalyDetectionEngine: statistical Z-score anomaly risk classification', () {
      final engine = AnomalyDetectionEngine();

      // Create an outlier transaction list (several ₹10 purchases, one ₹2000 outlier)
      final normalTx = List.generate(
        10,
        (index) => Transaction(
          id: 'n_$index',
          amount: 10.0,
          merchant: 'Store',
          category: 'Food',
          date: now,
          paymentMethod: 'Cash',
          isRecurring: false,
        ),
      );

      final outlierTx = Transaction(
        id: 'outlier',
        amount: 2000.0,
        merchant: 'Jewelry Shop',
        category: 'Shopping',
        date: now,
        paymentMethod: 'Credit Card',
        isRecurring: false,
      );

      final combined = [...normalTx, outlierTx];

      final anomalies = engine.detectAnomalies(combined);
      expect(anomalies.length, 1);
      expect(anomalies.first.transactionId, 'outlier');
      expect(anomalies.first.riskLevel, 'HIGH');
      expect(anomalies.first.message, contains('Jewelry Shop'));
    });

    test('BehavioralEngine: overspending, subscriptions, and impulse triggers', () {
      final engine = BehavioralEngine();

      // Add weekend dates (June 20, 2026 is Saturday, June 21 is Sunday)
      final weekendTxs = [
        Transaction(
          id: 'w1',
          amount: 200.0,
          merchant: 'Weekend Club',
          category: 'Entertainment',
          date: DateTime(2026, 6, 20), // Saturday
          paymentMethod: 'Card',
          isRecurring: false,
        ),
        Transaction(
          id: 'w2',
          amount: 300.0,
          merchant: 'Weekend Dining',
          category: 'Food',
          date: DateTime(2026, 6, 21), // Sunday
          paymentMethod: 'Card',
          isRecurring: false,
        ),
        Transaction(
          id: 'wd1',
          amount: 30.0,
          merchant: 'Work Lunch',
          category: 'Food',
          date: DateTime(2026, 6, 17), // Wednesday
          paymentMethod: 'Card',
          isRecurring: false,
        ),
      ];

      final insights = engine.analyzeBehavior(weekendTxs);
      expect(insights, isNotEmpty);
      expect(insights.any((i) => i.title == 'Weekend Overspending'), isTrue);
    });

    test('HealthCalculator: score weight calculation accuracy', () {
      final calculator = HealthCalculator();

      final score = calculator.calculateHealthScore(
        savingsRatioScore: 80.0,
        budgetAdherenceScore: 90.0,
        spendingStabilityScore: 70.0,
        anomalyFrequencyScore: 100.0,
        goalProgressScore: 50.0,
      );

      // (80 * 0.3) + (90 * 0.25) + (70 * 0.15) + (100 * 0.15) + (50 * 0.15)
      // = 24.0 + 22.5 + 10.5 + 15.0 + 7.5 = 79.5
      expect(score, closeTo(79.5, 0.01));
    });

    test('AdvisorChatEngine: query-driven dynamic response validation', () {
      final chatEngine = AdvisorChatEngine();
      final predictions = {'Food': 150.0, 'Rent': 1200.0};
      final budgets = [
        Budget(category: 'Food', monthlyLimit: 200.0, spentAmount: 180.0),
      ];
      final goals = [
        FinancialGoal(id: 'g1', name: 'Emergency Fund', targetAmount: 1000.0, currentAmount: 400.0, targetDate: now),
      ];

      // Test "Where am I spending the most?"
      final mostSpendRes = chatEngine.processQuery(
        'Where am I spending the most?',
        transactions: sampleTransactions,
        budgets: budgets,
        goals: goals,
        predictions: predictions,
        healthScore: 75.0,
        initialBalance: 5000.0,
      );
      expect(mostSpendRes, contains('Rent'));
      expect(mostSpendRes, contains('1200.00'));

      // Test "Can I save ₹500 next month?"
      final saveQueryRes = chatEngine.processQuery(
        'Can I save 500 next month?',
        transactions: sampleTransactions,
        budgets: budgets,
        goals: goals,
        predictions: predictions,
        healthScore: 75.0,
        initialBalance: 5000.0,
      );
      expect(saveQueryRes, isNotEmpty);

      // Test "How to save money?"
      final howToSaveRes = chatEngine.processQuery(
        'How can I save money?',
        transactions: sampleTransactions,
        budgets: budgets,
        goals: goals,
        predictions: predictions,
        healthScore: 75.0,
        initialBalance: 5000.0,
      );
      expect(howToSaveRes, contains('Reduce'));
    });
  });
}
