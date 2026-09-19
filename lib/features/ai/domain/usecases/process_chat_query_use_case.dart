import '../entities/chat_message.dart';
import '../repositories/ai_repository.dart';

/// Use case for sending queries to and receiving answers from the AI assistant chat.
class ProcessChatQueryUseCase {
  final AIRepository _repository;

  ProcessChatQueryUseCase(this._repository);

  /// Executes the request to process a chat message query.
  Future<ChatMessage> call(String query) {
    return _repository.processChatQuery(query);
  }
}
