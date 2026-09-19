import '../entities/user_session.dart';

/// Contract defining authentication and session operations.
abstract class AuthRepository {
  /// Logs in a user with the provided [email] and [password].
  Future<UserSession> login(String email, String password);

  /// Signs up a new user with [username], [email], and [password].
  Future<UserSession> signup(String username, String email, String password);

  /// Retrieves the current user session, if one exists.
  Future<UserSession?> getSession();

  /// Logs out the current user session.
  Future<void> logout();
}
