import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/financial_goal.dart';
import '../../domain/repositories/goal_repository.dart';

/// State notifier for managing financial goal lists.
class GoalNotifier extends StateNotifier<List<FinancialGoal>> {
  final GoalRepository _repository;

  GoalNotifier(this._repository) : super([]) {
    loadGoals();
  }

  /// Loads goals from database.
  Future<void> loadGoals() async {
    state = await _repository.getGoals();
  }

  /// Adds a new financial goal and reloads list.
  Future<void> addGoal(FinancialGoal goal) async {
    await _repository.addGoal(goal);
    await loadGoals();
  }

  /// Updates progress current saved amount for a goal and reloads list.
  Future<void> updateGoalProgress(String id, double currentAmount) async {
    await _repository.updateGoalProgress(id, currentAmount);
    await loadGoals();
  }

  /// Deletes a goal and reloads list.
  Future<void> deleteGoal(String id) async {
    await _repository.deleteGoal(id);
    await loadGoals();
  }
}

/// Provider for [GoalNotifier] exposing financial goals state list.
final goalProvider = StateNotifierProvider<GoalNotifier, List<FinancialGoal>>((ref) {
  final repository = ref.watch(goalRepositoryProvider);
  return GoalNotifier(repository);
});
