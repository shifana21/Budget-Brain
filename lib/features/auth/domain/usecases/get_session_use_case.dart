import '../entities/user_session.dart';
import '../repositories/auth_repository.dart';

/// Use case for retrieving the current active user session.
class GetSessionUseCase {
  final AuthRepository _repository;

  GetSessionUseCase(this._repository);

  /// Executes the request to retrieve the current session.
  Future<UserSession?> call() {
    return _repository.getSession();
  }
}
