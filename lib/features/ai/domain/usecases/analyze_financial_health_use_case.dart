import '../repositories/ai_repository.dart';

/// Use case for analyzing the user's financial health.
class AnalyzeFinancialHealthUseCase {
  final AIRepository _repository;

  AnalyzeFinancialHealthUseCase(this._repository);

  /// Executes the request to analyze overall financial health.
  Future<String> call() {
    return _repository.analyzeFinancialHealth();
  }
}
