import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_auth_data_source.dart';
import '../models/user_session_model.dart';

/// Implementation of the [AuthRepository] contract.
class AuthRepositoryImpl implements AuthRepository {
  final LocalAuthDataSource _localDataSource;

  AuthRepositoryImpl(this._localDataSource);

  @override
  Future<UserSession> login(String email, String password) async {
    // Generate a mockup session for login
    final session = UserSessionModel(
      userId: DateTime.now().millisecondsSinceEpoch.toString(),
      username: email.split('@').first,
      email: email,
      isGuest: false,
    );
    await _localDataSource.saveSession(session);
    return session;
  }

  @override
  Future<UserSession> signup(String username, String email, String password) async {
    // Generate a mockup session for signup
    final session = UserSessionModel(
      userId: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      email: email,
      isGuest: false,
    );
    await _localDataSource.saveSession(session);
    return session;
  }

  @override
  Future<UserSession?> getSession() async {
    return _localDataSource.getSession();
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearSession();
  }
}
