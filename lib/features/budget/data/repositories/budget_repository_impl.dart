import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../datasources/local_budget_data_source.dart';
import '../models/budget_model.dart';

/// Implementation of the [BudgetRepository] contract.
class BudgetRepositoryImpl implements BudgetRepository {
  final LocalBudgetDataSource _localDataSource;

  BudgetRepositoryImpl(this._localDataSource);

  @override
  Future<List<Budget>> getBudgets() async {
    return _localDataSource.getBudgets();
  }

  @override
  Future<void> updateBudgetLimit(String category, double limit) async {
    final existing = await _localDataSource.getBudget(category);
    final updated = BudgetModel(
      category: category,
      monthlyLimit: limit,
      spentAmount: existing?.spentAmount ?? 0.0,
    );
    await _localDataSource.saveBudget(updated);
  }

  @override
  Future<Budget?> getBudgetForCategory(String category) async {
    return _localDataSource.getBudget(category);
  }

  @override
  Future<void> syncSpentAmounts(List<Transaction> transactions) async {
    final budgets = await _localDataSource.getBudgets();
    final now = DateTime.now();

    for (final budget in budgets) {
      // Calculate spent amount for current month
      final monthlySpent = transactions
          .where((tx) =>
              tx.category == budget.category &&
              tx.date.year == now.year &&
              tx.date.month == now.month)
          .fold<double>(0.0, (sum, tx) => sum + tx.amount);

      final updated = BudgetModel(
        category: budget.category,
        monthlyLimit: budget.monthlyLimit,
        spentAmount: monthlySpent,
      );
      await _localDataSource.saveBudget(updated);
    }
  }
}
