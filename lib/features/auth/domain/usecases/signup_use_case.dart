import '../entities/user_session.dart';
import '../repositories/auth_repository.dart';

/// Use case for registering a new user.
class SignupUseCase {
  final AuthRepository _repository;

  SignupUseCase(this._repository);

  /// Executes the signup request.
  Future<UserSession> call(String username, String email, String password) {
    return _repository.signup(username, email, password);
  }
}
