import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/services/advisor_chat_engine.dart';

// Providers dependencies
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../goals/presentation/providers/goal_provider.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import 'ai_provider.dart';

/// State notifier for managing advisory chat conversations.
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;
  final AdvisorChatEngine _chatEngine;

  ChatNotifier(this._ref)
      : _chatEngine = AdvisorChatEngine(),
        super([]);

  /// Sends a query message, processes it via [AdvisorChatEngine], and appends both to the chat history.
  Future<void> sendQuery(String query) async {
    final userMessage = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_user',
      text: query,
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Append user message immediately
    state = [...state, userMessage];

    // Fetch active financial metrics context dynamically on-demand
    final transactions = _ref.read(transactionProvider);
    final budgets = _ref.read(budgetProvider);
    final goals = _ref.read(goalProvider);
    final aiState = _ref.read(aiProvider);
    final wallet = _ref.read(walletProvider);

    final replyText = _chatEngine.processQuery(
      query,
      transactions: transactions,
      budgets: budgets,
      goals: goals,
      predictions: aiState.predictions,
      healthScore: aiState.healthScore,
      initialBalance: wallet?.initialBalance ?? 0.0,
    );

    final botMessage = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_bot',
      text: replyText,
      isUser: false,
      timestamp: DateTime.now(),
    );

    // Append assistant response
    state = [...state, botMessage];
  }
}

/// Provider for [ChatNotifier] managing list of chat logs.
final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref);
});
