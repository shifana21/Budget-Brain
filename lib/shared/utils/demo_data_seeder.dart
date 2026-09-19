import 'dart:math';

import '../../features/auth/domain/entities/user_session.dart';
import '../../features/auth/data/models/user_session_model.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/budget/domain/entities/budget.dart';
import '../../features/budget/data/models/budget_model.dart';
import '../../features/goals/domain/entities/financial_goal.dart';
import '../../features/goals/data/models/financial_goal_model.dart';
import '../../features/ai/domain/entities/anomaly.dart';
import '../../features/ai/domain/entities/insight.dart';

/// Generates realistic demo data for BudgetBrain testing and demonstration.
class DemoDataSeeder {
  static final Random _random = Random(42); // Fixed seed for consistency

  static const List<String> _categories = [
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Health',
    'Entertainment',
  ];

  static const Map<String, List<String>> _merchants = {
    'Food': ['Swiggy', 'Zomato', 'Domino\'s', 'Starbucks', 'McDonald\'s'],
    'Travel': ['Uber', 'Ola', 'MakeMyTrip', 'IRCTC', 'OYO'],
    'Shopping': ['Amazon', 'Flipkart', 'Myntra', 'Ajio', 'Croma'],
    'Bills': ['Electricity Board', 'Jio Fiber', 'Airtel', 'Gas Agency'],
    'Health': ['Pharmacy', 'Hospital', 'Clinic', 'Diagnostic Center'],
    'Entertainment': ['Netflix', 'Spotify', 'Hotstar', 'BookMyShow', 'PVR'],
  };

  static const List<String> _paymentMethods = [
    'Credit Card',
    'Debit Card',
    'UPI',
    'Net Banking',
    'Cash',
  ];

  /// Generates 90 days of realistic transaction data.
  static List<Transaction> generateTransactions({int days = 90}) {
    final transactions = <Transaction>[];
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final transactionsForDay = _random.nextInt(4) + 1; // 1-4 transactions per day

      for (int j = 0; j < transactionsForDay; j++) {
        final category = _categories[_random.nextInt(_categories.length)];
        final merchants = _merchants[category]!;
        final merchant = merchants[_random.nextInt(merchants.length)];
        final amount = _generateAmount(category);
        final paymentMethod = _paymentMethods[_random.nextInt(_paymentMethods.length)];
        final isRecurring = _random.nextDouble() < 0.15; // 15% recurring

        final model = TransactionModel(
          id: '${date.millisecondsSinceEpoch}_$j',
          amount: amount,
          merchant: merchant,
          category: category,
          date: date,
          paymentMethod: paymentMethod,
          isRecurring: isRecurring,
          notes: isRecurring ? 'Monthly subscription' : null,
        );
        transactions.add(model.toEntity());
      }
    }

    return transactions;
  }

  /// Generates realistic amount based on category.
  static double _generateAmount(String category) {
    switch (category) {
      case 'Food':
        return 200 + _random.nextDouble() * 800;
      case 'Travel':
        return 100 + _random.nextDouble() * 1500;
      case 'Shopping':
        return 500 + _random.nextDouble() * 3000;
      case 'Bills':
        return 500 + _random.nextDouble() * 2000;
      case 'Health':
        return 200 + _random.nextDouble() * 2000;
      case 'Entertainment':
        return 100 + _random.nextDouble() * 500;
      default:
        return 100 + _random.nextDouble() * 1000;
    }
  }

  /// Generates sample budgets for all categories.
  static List<Budget> generateBudgets() {
    return _categories.map((category) {
      final limit = _generateBudgetLimit(category);
      return BudgetModel(
        category: category,
        monthlyLimit: limit,
        spentAmount: 0.0, // Will be calculated by sync
      );
    }).toList();
  }

  /// Generates realistic budget limit based on category.
  static double _generateBudgetLimit(String category) {
    switch (category) {
      case 'Food':
        return 5000 + _random.nextDouble() * 3000;
      case 'Travel':
        return 3000 + _random.nextDouble() * 4000;
      case 'Shopping':
        return 4000 + _random.nextDouble() * 6000;
      case 'Bills':
        return 3000 + _random.nextDouble() * 3000;
      case 'Health':
        return 2000 + _random.nextDouble() * 3000;
      case 'Entertainment':
        return 1500 + _random.nextDouble() * 2000;
      default:
        return 3000;
    }
  }

  /// Generates sample financial goals.
  static List<FinancialGoal> generateGoals() {
    return [
      FinancialGoalModel(
        id: 'goal_1',
        name: 'Emergency Fund',
        targetAmount: 100000,
        currentAmount: 45000 + _random.nextDouble() * 20000,
        targetDate: DateTime.now().add(const Duration(days: 180)),
      ),
      FinancialGoalModel(
        id: 'goal_2',
        name: 'Vacation to Goa',
        targetAmount: 50000,
        currentAmount: 15000 + _random.nextDouble() * 10000,
        targetDate: DateTime.now().add(const Duration(days: 120)),
      ),
      FinancialGoalModel(
        id: 'goal_3',
        name: 'New Laptop',
        targetAmount: 80000,
        currentAmount: 30000 + _random.nextDouble() * 15000,
        targetDate: DateTime.now().add(const Duration(days: 270)),
      ),
    ];
  }

  /// Generates sample AI insights.
  static List<Insight> generateInsights() {
    return [
      Insight(
        title: 'Weekend Overspending',
        description: 'Your weekend spending is 35% higher than weekdays.',
        impactScore: 7.5,
      ),
      Insight(
        title: 'Food Delivery Trend',
        description: 'Food delivery expenses increased 18% this month.',
        impactScore: 6.2,
      ),
      Insight(
        title: 'Subscription Optimization',
        description: 'You can save ₹1,500 monthly by reducing unused subscriptions.',
        impactScore: 8.0,
      ),
      Insight(
        title: 'Shopping Alert',
        description: 'Shopping exceeded normal spending by 28% this month.',
        impactScore: 7.8,
      ),
    ];
  }

  /// Generates sample anomalies.
  static List<Anomaly> generateAnomalies() {
    return [
      Anomaly(
        transactionId: 'tx_anomaly_1',
        riskLevel: 'HIGH',
        message: 'Unusual transaction: spent ₹8,500 at Amazon. (Z-score: 2.45)',
      ),
      Anomaly(
        transactionId: 'tx_anomaly_2',
        riskLevel: 'MEDIUM',
        message: 'Unusual transaction: spent ₹2,200 at Uber. (Z-score: 1.32)',
      ),
    ];
  }

  /// Generates a demo user session.
  static UserSession generateUserSession() {
    return UserSessionModel(
      userId: 'demo_user_123',
      username: 'Demo User',
      email: 'demo@budgetbrain.ai',
      isGuest: false,
    );
  }
}
