import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';

/// State notifier for managing authentication session state.
class AuthNotifier extends StateNotifier<UserSession?> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(null) {
    checkSession();
  }

  /// Checks if a cached user session exists and updates state.
  Future<void> checkSession() async {
    state = await _repository.getSession();
  }

  /// Authenticates a user with [email] and [password].
  Future<void> login(String email, String password) async {
    final session = await _repository.login(email, password);
    state = session;
  }

  /// Registers a new user with [username], [email], and [password].
  Future<void> signup(String username, String email, String password) async {
    final session = await _repository.signup(username, email, password);
    state = session;
  }

  /// Clears the active authentication session.
  Future<void> logout() async {
    await _repository.logout();
    state = null;
  }

  /// Starts a local guest session without persisting credentials.
  void loginAsGuest() {
    state = const UserSession(
      userId: 'guest',
      username: 'Guest',
      email: 'guest@budgetbrain.local',
      isGuest: true,
    );
  }
}

/// Provider for [AuthNotifier] exposing the current user session state.
final authProvider = StateNotifierProvider<AuthNotifier, UserSession?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
