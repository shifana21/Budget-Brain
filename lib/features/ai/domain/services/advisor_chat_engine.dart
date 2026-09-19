import '../../../transactions/domain/entities/transaction.dart';
import '../../../budget/domain/entities/budget.dart';
import '../../../goals/domain/entities/financial_goal.dart';

/// Offline AI advisor chat service utilizing local financial context.
class AdvisorChatEngine {
  /// Processes a user's [query] utilizing context parameters to build custom advice.
  String processQuery(
    String query, {
    required List<Transaction> transactions,
    required List<Budget> budgets,
    required List<FinancialGoal> goals,
    required Map<String, double> predictions,
    required double healthScore,
    required double initialBalance,
  }) {
    final q = query.toLowerCase();

    // 1. Where did I spend most money? / What is my biggest expense category?
    if (q.contains('where') && (q.contains('spend') || q.contains('most'))) {
      return _generateMostSpendingResponse(transactions);
    }

    if (q.contains('biggest') || q.contains('highest') || q.contains('largest')) {
      return _generateMostSpendingResponse(transactions);
    }

    // 2. Can I save [amount] next month?
    if (q.contains('can i save') || q.contains('save')) {
      final match = RegExp(r'\d+').firstMatch(q);
      if (match != null) {
        final amountToSave = double.parse(match.group(0)!);
        return _generateCanISaveResponse(amountToSave, transactions, healthScore, initialBalance);
      }
    }

    // 3. How can I save money?
    if (q.contains('how can i save') || q.contains('how to save') || q.contains('save money')) {
      return _generateHowToSaveResponse(transactions, budgets, healthScore);
    }

    // 4. How healthy are my finances? / What is my financial health?
    if (q.contains('healthy') || q.contains('health') || q.contains('financial health')) {
      return _generateHealthResponse(healthScore, transactions, budgets, goals);
    }

    // 5. What goal can I reach fastest?
    if (q.contains('goal') && (q.contains('fastest') || q.contains('reach') || q.contains('complete'))) {
      return _generateGoalResponse(goals, transactions);
    }

    // 6. Spending predictions
    if (q.contains('predict') || q.contains('forecast')) {
      return _generatePredictionResponse(predictions);
    }

    // 7. Default / General Summary Response
    return _generateDefaultSummary(healthScore, goals, predictions);
  }

  String _generateMostSpendingResponse(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return "I don't see any transactions in your history yet to analyze your spending.";
    }

    final Map<String, double> categorySums = {};
    for (final tx in transactions) {
      categorySums[tx.category] = (categorySums[tx.category] ?? 0.0) + tx.amount;
    }

    final sorted = categorySums.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final highest = sorted.first;
    final buffer = StringBuffer()
      ..write("Your biggest expense category is **${highest.key}** with a total of ₹${highest.value.toStringAsFixed(2)}.");

    if (sorted.length > 1) {
      final second = sorted[1];
      buffer.write(" Your next highest is **${second.key}** (₹${second.value.toStringAsFixed(2)}).");
    }

    return buffer.toString();
  }

  String _generateCanISaveResponse(double amount, List<Transaction> transactions, double healthScore, double initialBalance) {
    final totalSpent = transactions.fold<double>(0.0, (sum, tx) => sum + tx.amount);
    final remainingBalance = initialBalance - totalSpent;
    
    if (remainingBalance >= amount) {
      return "Yes! Based on your current spending patterns, you have ₹${remainingBalance.toStringAsFixed(0)} remaining, which exceeds your goal of ₹${amount.toStringAsFixed(0)}. Keep it up!";
    } else {
      final deficit = amount - remainingBalance;
      return "Saving ₹${amount.toStringAsFixed(0)} next month will be challenging. You currently have ₹${remainingBalance.toStringAsFixed(0)} remaining. To reach your target, you'll need to reduce spending by ₹${deficit.toStringAsFixed(0)} next month.";
    }
  }

  String _generateHowToSaveResponse(List<Transaction> transactions, List<Budget> budgets, double healthScore) {
    if (transactions.isEmpty) {
      return "To start saving money, I recommend tracking your expenses and setting up monthly category budgets. Once you add some transactions, I can offer personalized tips.";
    }

    final Map<String, double> categorySums = {};
    for (final tx in transactions) {
      categorySums[tx.category] = (categorySums[tx.category] ?? 0.0) + tx.amount;
    }

    final sorted = categorySums.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final highest = sorted.first;

    final buffer = StringBuffer()
      ..write("Here are personalized savings tips for you:\n")
      ..write("1. **Reduce ${highest.key} spending**: This is your largest expense (₹${highest.value.toStringAsFixed(2)} total).\n");

    // Check if any budgets are exceeded
    final exceededBudgets = budgets.where((b) => b.spentAmount > b.monthlyLimit).toList();
    if (exceededBudgets.isNotEmpty) {
      buffer.write("2. **Stick to budgets**: You've exceeded budgets for: ${exceededBudgets.map((b) => b.category).join(', ')}. Sticking to limits will save money.\n");
    } else {
      buffer.write("2. **Optimize budgets**: Your adherence is good. Try lowering limits by 10% to boost savings.\n");
    }

    if (healthScore < 70) {
      buffer.write("3. **Improve Health Score**: Your score is ${healthScore.toStringAsFixed(0)}/100. Focus on reducing impulse spending.");
    } else {
      buffer.write("3. **Invest savings**: With a strong score of ${healthScore.toStringAsFixed(0)}/100, consider micro-investing options.");
    }

    return buffer.toString();
  }

  String _generateHealthResponse(double healthScore, List<Transaction> transactions, List<Budget> budgets, List<FinancialGoal> goals) {
    String status;
    if (healthScore >= 90) {
      status = 'Excellent';
    } else if (healthScore >= 75) {
      status = 'Good';
    } else if (healthScore >= 50) {
      status = 'Moderate';
    } else {
      status = 'Needs Improvement';
    }

    final buffer = StringBuffer()
      ..write("Your financial health score is **${healthScore.toStringAsFixed(0)}/100** ($status).\n\n");

    if (healthScore >= 75) {
      buffer.write("Great job! You're managing your finances well. Keep tracking expenses and maintaining your budget discipline.");
    } else if (healthScore >= 50) {
      buffer.write("Your finances are stable but there's room for improvement. Focus on reducing unnecessary expenses and building emergency savings.");
    } else {
      buffer.write("Your finances need attention. I recommend: 1) Track all expenses, 2) Set realistic budgets, 3) Reduce recurring subscriptions, 4) Build an emergency fund.");
    }

    return buffer.toString();
  }

  String _generateGoalResponse(List<FinancialGoal> goals, List<Transaction> transactions) {
    if (goals.isEmpty) {
      return "You don't have any financial goals set yet. Create a goal (like 'Emergency Fund' or 'Vacation') to start tracking your progress!";
    }

    // Calculate which goal can be reached fastest
    final totalMonthlySavings = _estimateMonthlySavings(transactions);
    
    if (totalMonthlySavings <= 0) {
      return "To reach your goals faster, you need to start saving regularly. Your current monthly savings estimate is low. Try reducing expenses in your highest spending category.";
    }

    final fastestGoals = goals.map((goal) {
      final remaining = goal.targetAmount - goal.currentAmount;
      final monthsToReach = remaining / totalMonthlySavings;
      return MapEntry(goal, monthsToReach);
    }).toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final fastest = fastestGoals.first;
    final months = (fastest.value).ceil();
    
    return "Your goal **'${fastest.key.name}'** can be reached fastest! You need ₹${(fastest.key.targetAmount - fastest.key.currentAmount).toStringAsFixed(0)} more. At your current savings rate of ₹${totalMonthlySavings.toStringAsFixed(0)}/month, you'll reach it in approximately $months months.";
  }

  double _estimateMonthlySavings(List<Transaction> transactions) {
    if (transactions.isEmpty) return 0.0;
    
    final totalSpent = transactions.fold<double>(0.0, (sum, tx) => sum + tx.amount);
    final estimatedIncome = totalSpent * 1.3; // Assume 30% savings potential
    return estimatedIncome - totalSpent;
  }

  String _generatePredictionResponse(Map<String, double> predictions) {
    if (predictions.isEmpty) {
      return "I don't have enough transaction data to generate spending predictions yet. Add more transactions to unlock forecasting.";
    }

    final sorted = predictions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final buffer = StringBuffer()
      ..write("Based on your spending patterns, here are my predictions for the next 30 days:\n\n");

    for (int i = 0; i < sorted.length && i < 3; i++) {
      buffer.write("• **${sorted[i].key}**: ₹${sorted[i].value.toStringAsFixed(0)}\n");
    }

    final totalPredicted = sorted.fold<double>(0.0, (sum, entry) => sum + entry.value);
    buffer.write("\n**Total predicted spending**: ₹${totalPredicted.toStringAsFixed(0)}");

    return buffer.toString();
  }

  String _generateDefaultSummary(double healthScore, List<FinancialGoal> goals, Map<String, double> predictions) {
    final buffer = StringBuffer()
      ..write("Hello! I'm your BudgetBrain advisor. Here's your financial summary:\n")
      ..write("- **Financial Health Score**: ${healthScore.toStringAsFixed(0)}/100\n");

    if (goals.isNotEmpty) {
      buffer.write("- **Active Goals**: ${goals.length} set. ");
      final firstGoal = goals.first;
      final progress = (firstGoal.currentAmount / firstGoal.targetAmount * 100).toStringAsFixed(0);
      buffer.write("'${firstGoal.name}' is $progress% complete.\n");
    } else {
      buffer.write("- **Active Goals**: None. Set a goal to start tracking.\n");
    }

    if (predictions.isNotEmpty) {
      final totalPredicted = predictions.values.fold<double>(0.0, (sum, val) => sum + val);
      buffer.write("- **30-Day Forecast**: ₹${totalPredicted.toStringAsFixed(0)} total predicted spending.");
    }

    return buffer.toString();
  }
}
