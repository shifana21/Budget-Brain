import 'package:hive/hive.dart';
import '../models/budget_model.dart';

/// Data source interface for local budget database operations.
abstract class LocalBudgetDataSource {
  Future<List<BudgetModel>> getBudgets();
  Future<void> saveBudget(BudgetModel budget);
  Future<BudgetModel?> getBudget(String category);
}

/// Hive implementation of [LocalBudgetDataSource].
class LocalBudgetDataSourceImpl implements LocalBudgetDataSource {
  final Box<BudgetModel> _box;

  LocalBudgetDataSourceImpl(this._box);

  @override
  Future<List<BudgetModel>> getBudgets() async {
    return _box.values.toList();
  }

  @override
  Future<void> saveBudget(BudgetModel budget) async {
    await _box.put(budget.category, budget);
  }

  @override
  Future<BudgetModel?> getBudget(String category) async {
    return _box.get(category);
  }
}
