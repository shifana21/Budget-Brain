import 'package:hive/hive.dart';
import '../../domain/entities/user_session.dart';

part 'user_session_model.g.dart';

@HiveType(typeId: 0)
class UserSessionModel extends UserSession {
  const UserSessionModel({
    required super.userId,
    required super.username,
    required super.email,
    required super.isGuest,
  });

  @HiveField(0)
  @override
  String get userId => super.userId;

  @HiveField(1)
  @override
  String get username => super.username;

  @HiveField(2)
  @override
  String get email => super.email;

  @HiveField(3)
  @override
  bool get isGuest => super.isGuest;

  factory UserSessionModel.fromEntity(UserSession entity) {
    return UserSessionModel(
      userId: entity.userId,
      username: entity.username,
      email: entity.email,
      isGuest: entity.isGuest,
    );
  }
}
