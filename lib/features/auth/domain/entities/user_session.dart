/// Represents a user session within the application.
class UserSession {
  final String userId;
  final String username;
  final String email;
  final bool isGuest;

  const UserSession({
    required this.userId,
    required this.username,
    required this.email,
    required this.isGuest,
  });
}
