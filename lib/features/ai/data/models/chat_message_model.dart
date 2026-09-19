import 'package:hive/hive.dart';
import '../../domain/entities/chat_message.dart';

part 'chat_message_model.g.dart';

@HiveType(typeId: 6)
class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.text,
    required super.isUser,
    required super.timestamp,
  });

  @HiveField(0)
  @override
  String get id => super.id;

  @HiveField(1)
  @override
  String get text => super.text;

  @HiveField(2)
  @override
  bool get isUser => super.isUser;

  @HiveField(3)
  @override
  DateTime get timestamp => super.timestamp;

  factory ChatMessageModel.fromEntity(ChatMessage entity) {
    return ChatMessageModel(
      id: entity.id,
      text: entity.text,
      isUser: entity.isUser,
      timestamp: entity.timestamp,
    );
  }
}
