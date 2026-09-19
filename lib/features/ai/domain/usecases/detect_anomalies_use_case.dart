import '../entities/anomaly.dart';
import '../repositories/ai_repository.dart';

/// Use case for detecting transactions anomaly patterns.
class DetectAnomaliesUseCase {
  final AIRepository _repository;

  DetectAnomaliesUseCase(this._repository);

  /// Executes the request to detect anomalies.
  Future<List<Anomaly>> call() {
    return _repository.detectAnomalies();
  }
}
