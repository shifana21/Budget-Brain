import '../entities/user_session.dart';
import '../repositories/auth_repository.dart';

/// Use case for logging in a user.
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  /// Executes the login request.
  Future<UserSession> call(String email, String password) {
    return _repository.login(email, password);
  }
}
