import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/transactions/presentation/providers/transaction_provider.dart';
import '../../features/budget/presentation/providers/budget_provider.dart';
import '../../features/goals/presentation/providers/goal_provider.dart';
import 'demo_data_seeder.dart';

/// Service to seed demo data into the application using providers.
class DemoDataService {
  final WidgetRef _ref;

  DemoDataService(this._ref);

  /// Seeds all demo data: transactions, budgets, goals, and user session.
  Future<void> seedAllData() async {
    // Seed user session
    _ref.read(authProvider.notifier).loginAsGuest();

    // Seed transactions
    final transactions = DemoDataSeeder.generateTransactions(days: 90);
    for (final tx in transactions) {
      await _ref.read(transactionProvider.notifier).addTransaction(tx);
    }

    // Seed budgets
    final budgets = DemoDataSeeder.generateBudgets();
    for (final budget in budgets) {
      await _ref.read(budgetProvider.notifier).updateBudgetLimit(
            budget.category,
            budget.monthlyLimit,
          );
    }

    // Sync budget spent amounts with transactions
    await _ref.read(budgetProvider.notifier).syncSpentAmounts(transactions);

    // Seed goals
    final goals = DemoDataSeeder.generateGoals();
    for (final goal in goals) {
      await _ref.read(goalProvider.notifier).addGoal(goal);
    }
  }

  /// Clears all demo data from the application.
  Future<void> clearAllData() async {
    // Clear transactions
    final transactions = _ref.read(transactionProvider);
    for (final tx in transactions) {
      await _ref.read(transactionProvider.notifier).deleteTransaction(tx.id);
    }

    // Clear goals
    final goals = _ref.read(goalProvider);
    for (final goal in goals) {
      await _ref.read(goalProvider.notifier).deleteGoal(goal.id);
    }

    // Clear budgets (by setting them to 0)
    final budgets = _ref.read(budgetProvider);
    for (final budget in budgets) {
      await _ref.read(budgetProvider.notifier).updateBudgetLimit(
            budget.category,
            0.0,
          );
    }

    // Logout
    await _ref.read(authProvider.notifier).logout();
  }
}
