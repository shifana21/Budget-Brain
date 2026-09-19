import '../repositories/ai_repository.dart';

/// Use case for predicting future monthly expenses.
class PredictExpensesUseCase {
  final AIRepository _repository;

  PredictExpensesUseCase(this._repository);

  /// Executes the request to predict expenses.
  Future<Map<String, double>> call() {
    return _repository.predictExpenses();
  }
}
