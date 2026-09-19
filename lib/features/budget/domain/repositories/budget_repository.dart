import '../entities/budget.dart';
import '../../../transactions/domain/entities/transaction.dart';

/// Contract defining budget operations.
abstract class BudgetRepository {
  /// Retrieves a list of all budgets.
  Future<List<Budget>> getBudgets();

  /// Updates the monthly limit for a budget [category].
  Future<void> updateBudgetLimit(String category, double limit);

  /// Retrieves the budget details for a specific [category].
  Future<Budget?> getBudgetForCategory(String category);

  /// Recalculates and updates spent amounts for all budgets based on [transactions].
  Future<void> syncSpentAmounts(List<Transaction> transactions);
}
