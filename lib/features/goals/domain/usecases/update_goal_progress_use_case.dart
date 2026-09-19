import '../repositories/goal_repository.dart';

/// Use case for updating the progress of a financial goal.
class UpdateGoalProgressUseCase {
  final GoalRepository _repository;

  UpdateGoalProgressUseCase(this._repository);

  /// Executes the request to update progress.
  Future<void> call(String id, double currentAmount) {
    return _repository.updateGoalProgress(id, currentAmount);
  }
}
