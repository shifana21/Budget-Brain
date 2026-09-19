import '../entities/financial_goal.dart';

/// Contract defining financial goals operations.
abstract class GoalRepository {
  /// Retrieves a list of all goals.
  Future<List<FinancialGoal>> getGoals();

  /// Adds a new financial goal.
  Future<void> addGoal(FinancialGoal goal);

  /// Updates the current saved amount of a goal.
  Future<void> updateGoalProgress(String id, double currentAmount);

  /// Deletes a financial goal by [id].
  Future<void> deleteGoal(String id);
}
