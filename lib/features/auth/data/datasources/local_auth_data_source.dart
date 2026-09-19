import 'package:hive/hive.dart';
import '../models/user_session_model.dart';

/// Data source interface for managing authenticated sessions locally.
abstract class LocalAuthDataSource {
  Future<void> saveSession(UserSessionModel session);
  Future<UserSessionModel?> getSession();
  Future<void> clearSession();
}

/// Hive implementation of [LocalAuthDataSource].
class LocalAuthDataSourceImpl implements LocalAuthDataSource {
  final Box<UserSessionModel> _box;

  LocalAuthDataSourceImpl(this._box);

  static const _sessionKey = 'current_session';

  @override
  Future<void> saveSession(UserSessionModel session) async {
    await _box.put(_sessionKey, session);
  }

  @override
  Future<UserSessionModel?> getSession() async {
    return _box.get(_sessionKey);
  }

  @override
  Future<void> clearSession() async {
    await _box.delete(_sessionKey);
  }
}
