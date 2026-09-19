import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../../transactions/domain/entities/transaction.dart';

/// State notifier for managing budget limits and spent category tracking.
class BudgetNotifier extends StateNotifier<List<Budget>> {
  final BudgetRepository _repository;

  BudgetNotifier(this._repository) : super([]) {
    loadBudgets();
  }

  /// Loads all category budgets from repository.
  Future<void> loadBudgets() async {
    state = await _repository.getBudgets();
  }

  /// Updates a category monthly budget limit and reloads state.
  Future<void> updateBudgetLimit(String category, double limit) async {
    await _repository.updateBudgetLimit(category, limit);
    await loadBudgets();
  }

  /// Syncs spent amounts with current transactions and reloads state.
  Future<void> syncSpentAmounts(List<Transaction> transactions) async {
    await _repository.syncSpentAmounts(transactions);
    await loadBudgets();
  }
}

/// Provider for [BudgetNotifier] exposing budget category lists.
final budgetProvider = StateNotifierProvider<BudgetNotifier, List<Budget>>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return BudgetNotifier(repository);
});
