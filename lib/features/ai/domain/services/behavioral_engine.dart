import '../../../transactions/domain/entities/transaction.dart';
import '../entities/insight.dart';

/// Service for extracting behavioral spending patterns and insights.
class BehavioralEngine {
  /// Analyzes the spending patterns from [transactions] to generate insights.
  List<Insight> analyzeBehavior(List<Transaction> transactions) {
    final List<Insight> insights = [];
    if (transactions.isEmpty) return insights;

    // 1. Weekend vs. Weekday Analysis
    _analyzeWeekendSpending(transactions, insights);

    // 2. Impulse Spending Detection
    _analyzeImpulseSpending(transactions, insights);

    // 3. Subscription Leakage Detection
    _analyzeSubscriptionLeakage(transactions, insights);

    // 4. Category Trend Analysis (Month-over-Month)
    _analyzeCategoryTrends(transactions, insights);

    // 5. Subscription Savings Potential
    _analyzeSubscriptionSavings(transactions, insights);

    // 6. Shopping Pattern Analysis
    _analyzeShoppingPatterns(transactions, insights);

    return insights;
  }

  void _analyzeWeekendSpending(List<Transaction> transactions, List<Insight> insights) {
    double weekendSum = 0.0;
    int weekendCount = 0;
    double weekdaySum = 0.0;
    int weekdayCount = 0;

    for (final tx in transactions) {
      final weekday = tx.date.weekday;
      if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
        weekendSum += tx.amount;
        weekendCount++;
      } else {
        weekdaySum += tx.amount;
        weekdayCount++;
      }
    }

    final weekendAvg = weekendCount > 0 ? weekendSum / weekendCount : 0.0;
    final weekdayAvg = weekdayCount > 0 ? weekdaySum / weekdayCount : 0.0;

    if (weekdayAvg > 0 && weekendAvg > weekdayAvg) {
      final percentHigher = ((weekendAvg - weekdayAvg) / weekdayAvg) * 100;
      if (percentHigher >= 10.0) {
        insights.add(Insight(
          title: 'Weekend Overspending',
          description: 'You spend ${percentHigher.toStringAsFixed(0)}% more on weekends.',
          impactScore: (percentHigher / 15.0).clamp(1.0, 10.0),
        ));
      }
    }
  }

  void _analyzeImpulseSpending(List<Transaction> transactions, List<Insight> insights) {
    final totalAmount = transactions.fold<double>(0.0, (sum, tx) => sum + tx.amount);
    final overallAvg = totalAmount / transactions.length;

    for (final tx in transactions) {
      // If a single one-off transaction is > 3x the average and > ₹300
      if (!tx.isRecurring && tx.amount > 300.0 && tx.amount > (overallAvg * 3.0)) {
        insights.add(Insight(
          title: 'Impulse Spending Alert',
          description: 'Large single-time purchase of ₹${tx.amount.toStringAsFixed(2)} at ${tx.merchant} detected.',
          impactScore: (tx.amount / 150.0).clamp(5.0, 9.5),
        ));
      }
    }
  }

  void _analyzeSubscriptionLeakage(List<Transaction> transactions, List<Insight> insights) {
    // Count transactions marked as recurring
    final recurringCount = transactions.where((tx) => tx.isRecurring).length;

    if (recurringCount > 0) {
      insights.add(Insight(
        title: 'Subscription Leakage',
        description: 'You have $recurringCount recurring subscriptions.',
        impactScore: (recurringCount * 1.5).clamp(3.0, 8.0),
      ));
    }
  }

  void _analyzeCategoryTrends(List<Transaction> transactions, List<Insight> insights) {
    final now = DateTime.now();
    final thisMonth = now.month;
    final lastMonth = thisMonth == 1 ? 12 : thisMonth - 1;
    final thisYear = thisMonth == 1 ? now.year - 1 : now.year;

    // Group by category and month
    final Map<String, Map<int, double>> categoryMonthTotals = {};

    for (final tx in transactions) {
      categoryMonthTotals.putIfAbsent(tx.category, () => {});
      final month = tx.date.month;
      final year = tx.date.year;
      final key = year * 100 + month; // Unique key for year-month

      categoryMonthTotals[tx.category]![key] = 
          (categoryMonthTotals[tx.category]![key] ?? 0.0) + tx.amount;
    }

    // Analyze Food category specifically
    if (categoryMonthTotals.containsKey('Food')) {
      final foodTotals = categoryMonthTotals['Food']!;
      final thisMonthKey = now.year * 100 + thisMonth;
      final lastMonthKey = thisYear * 100 + lastMonth;

      final thisMonthFood = foodTotals[thisMonthKey] ?? 0.0;
      final lastMonthFood = foodTotals[lastMonthKey] ?? 0.0;

      if (lastMonthFood > 0 && thisMonthFood > lastMonthFood) {
        final percentIncrease = ((thisMonthFood - lastMonthFood) / lastMonthFood) * 100;
        if (percentIncrease >= 15.0) {
          insights.add(Insight(
            title: 'Food Delivery Trend',
            description: 'Food delivery increased ${percentIncrease.toStringAsFixed(0)}% this month.',
            impactScore: (percentIncrease / 20.0).clamp(5.0, 9.0),
          ));
        }
      }
    }
  }

  void _analyzeSubscriptionSavings(List<Transaction> transactions, List<Insight> insights) {
    final recurringTransactions = transactions.where((tx) => tx.isRecurring).toList();
    
    if (recurringTransactions.length >= 2) {
      // Calculate potential savings by reducing subscriptions
      final monthlySubscriptionTotal = recurringTransactions
          .fold<double>(0.0, (sum, tx) => sum + tx.amount);
      
      // Assume 20% could be saved by optimizing
      final potentialSavings = monthlySubscriptionTotal * 0.2;
      
      if (potentialSavings >= 500) {
        insights.add(Insight(
          title: 'Subscription Optimization',
          description: 'You can save ₹${potentialSavings.toStringAsFixed(0)} monthly by reducing subscriptions.',
          impactScore: (potentialSavings / 500.0).clamp(6.0, 9.5),
        ));
      }
    }
  }

  void _analyzeShoppingPatterns(List<Transaction> transactions, List<Insight> insights) {
    final shoppingTransactions = transactions
        .where((tx) => tx.category == 'Shopping')
        .toList();

    if (shoppingTransactions.length < 5) return;

    final now = DateTime.now();
    final thisMonthShopping = shoppingTransactions
        .where((tx) => tx.date.month == now.month && tx.date.year == now.year)
        .fold<double>(0.0, (sum, tx) => sum + tx.amount);

    // Calculate average monthly shopping over last 3 months
    final last3MonthsShopping = <double>[];
    for (int i = 1; i <= 3; i++) {
      final targetMonth = DateTime(now.year, now.month - i);
      final monthTotal = shoppingTransactions
          .where((tx) => tx.date.month == targetMonth.month && tx.date.year == targetMonth.year)
          .fold<double>(0.0, (sum, tx) => sum + tx.amount);
      if (monthTotal > 0) last3MonthsShopping.add(monthTotal);
    }

    if (last3MonthsShopping.isNotEmpty) {
      final avgMonthlyShopping = last3MonthsShopping.reduce((a, b) => a + b) / last3MonthsShopping.length;
      
      if (avgMonthlyShopping > 0 && thisMonthShopping > avgMonthlyShopping) {
        final percentAbove = ((thisMonthShopping - avgMonthlyShopping) / avgMonthlyShopping) * 100;
        if (percentAbove >= 20.0) {
          insights.add(Insight(
            title: 'Shopping Alert',
            description: 'Shopping exceeded normal spending by ${percentAbove.toStringAsFixed(0)}% this month.',
            impactScore: (percentAbove / 25.0).clamp(6.0, 9.0),
          ));
        }
      }
    }
  }
}
