import '../entities/insight.dart';
import '../repositories/ai_repository.dart';

/// Use case for generating financial planning insights.
class GenerateInsightsUseCase {
  final AIRepository _repository;

  GenerateInsightsUseCase(this._repository);

  /// Executes the request to generate insights.
  Future<List<Insight>> call() {
    return _repository.generateInsights();
  }
}
