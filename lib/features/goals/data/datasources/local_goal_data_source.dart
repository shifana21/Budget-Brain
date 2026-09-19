import 'package:hive/hive.dart';
import '../models/financial_goal_model.dart';

/// Data source interface for local goal database operations.
abstract class LocalGoalDataSource {
  Future<List<FinancialGoalModel>> getGoals();
  Future<void> saveGoal(FinancialGoalModel goal);
  Future<void> deleteGoal(String id);
  Future<FinancialGoalModel?> getGoal(String id);
}

/// Hive implementation of [LocalGoalDataSource].
class LocalGoalDataSourceImpl implements LocalGoalDataSource {
  final Box<FinancialGoalModel> _box;

  LocalGoalDataSourceImpl(this._box);

  @override
  Future<List<FinancialGoalModel>> getGoals() async {
    return _box.values.toList();
  }

  @override
  Future<void> saveGoal(FinancialGoalModel goal) async {
    await _box.put(goal.id, goal);
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _box.delete(id);
  }

  @override
  Future<FinancialGoalModel?> getGoal(String id) async {
    return _box.get(id);
  }
}
