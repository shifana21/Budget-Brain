import '../../domain/entities/financial_goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/local_goal_data_source.dart';
import '../models/financial_goal_model.dart';

/// Implementation of the [GoalRepository] contract.
class GoalRepositoryImpl implements GoalRepository {
  final LocalGoalDataSource _localDataSource;

  GoalRepositoryImpl(this._localDataSource);

  @override
  Future<List<FinancialGoal>> getGoals() async {
    return _localDataSource.getGoals();
  }

  @override
  Future<void> addGoal(FinancialGoal goal) async {
    final model = FinancialGoalModel.fromEntity(goal);
    await _localDataSource.saveGoal(model);
  }

  @override
  Future<void> updateGoalProgress(String id, double currentAmount) async {
    final existing = await _localDataSource.getGoal(id);
    if (existing != null) {
      final updated = FinancialGoalModel(
        id: existing.id,
        name: existing.name,
        targetAmount: existing.targetAmount,
        currentAmount: currentAmount,
        targetDate: existing.targetDate,
      );
      await _localDataSource.saveGoal(updated);
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _localDataSource.deleteGoal(id);
  }
}
