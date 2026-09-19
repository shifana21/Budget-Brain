import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Db & Core Providers
import 'package:budget_brain/core/database/hive_db_manager.dart';
import 'package:budget_brain/core/providers/core_providers.dart';

// Feature Models & Providers
import 'package:budget_brain/features/auth/data/models/user_session_model.dart';
import 'package:budget_brain/features/auth/presentation/providers/auth_provider.dart';

import 'package:budget_brain/features/transactions/domain/entities/transaction.dart';
import 'package:budget_brain/features/transactions/data/models/transaction_model.dart';
import 'package:budget_brain/features/transactions/presentation/providers/transaction_provider.dart';

import 'package:budget_brain/features/budget/data/models/budget_model.dart';
import 'package:budget_brain/features/budget/presentation/providers/budget_provider.dart';

import 'package:budget_brain/features/goals/data/models/financial_goal_model.dart';

import 'package:budget_brain/features/ai/data/models/anomaly_model.dart';
import 'package:budget_brain/features/ai/data/models/insight_model.dart';
import 'package:budget_brain/features/ai/data/models/chat_message_model.dart';
import 'package:budget_brain/features/ai/presentation/providers/ai_provider.dart';
import 'package:budget_brain/features/ai/presentation/providers/chat_provider.dart';

void main() {
  late Directory tempDir;
  late HiveDbManager dbManager;
  late ProviderContainer container;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_provider_test');
    Hive.init(tempDir.path);

    // Register Hive Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserSessionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(BudgetModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(FinancialGoalModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AnomalyModelAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(InsightModelAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(ChatMessageModelAdapter());
    }

    dbManager = HiveDbManager();
    await dbManager.openBoxes();

    container = ProviderContainer(
      overrides: [
        dbManagerProvider.overrideWithValue(dbManager),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Riverpod State Providers Tests', () {
    test('Auth Provider login, check, and logout sequence', () async {
      final authNotifier = container.read(authProvider.notifier);
      expect(container.read(authProvider), isNull);

      await authNotifier.login('bob@example.com', 'password');
      final session = container.read(authProvider);
      expect(session, isNotNull);
      expect(session!.email, 'bob@example.com');

      // Logout
      await authNotifier.logout();
      expect(container.read(authProvider), isNull);
    });

    test('Transactions add/delete reactively recalculates AI Metrics state', () async {
      final txNotifier = container.read(transactionProvider.notifier);
      final budgetNotifier = container.read(budgetProvider.notifier);

      // Verify default AI State
      var aiState = container.read(aiProvider);
      expect(aiState.healthScore, 100.0);
      expect(aiState.predictions, isEmpty);
      expect(aiState.anomalies, isEmpty);

      // Set up a budget category limit
      await budgetNotifier.updateBudgetLimit('Utilities', 150.0);

      // Add normal transaction
      final tx1 = Transaction(
        id: 'tx1',
        amount: 50.0,
        merchant: 'Power Co',
        category: 'Utilities',
        date: DateTime.now().subtract(const Duration(days: 2)),
        paymentMethod: 'Auto-Pay',
        isRecurring: true,
      );
      await txNotifier.addTransaction(tx1);

      // Verify AI State updated reactively
      aiState = container.read(aiProvider);
      expect(aiState.predictions.containsKey('Utilities'), isTrue);
      expect(aiState.anomalies, isEmpty); // amount is low, no anomaly

      // Add outlier transaction (> 1000 and high deviation) to trigger anomaly & overspend
      final txOutlier = Transaction(
        id: 'tx2',
        amount: 8000.0,
        merchant: 'Luxury Store',
        category: 'Shopping',
        date: DateTime.now(),
        paymentMethod: 'Credit Card',
        isRecurring: false,
      );
      await txNotifier.addTransaction(txOutlier);

      // Verify AI State reactively computed predictions, anomalies, behaviors, and score
      aiState = container.read(aiProvider);
      expect(aiState.anomalies, isNotEmpty);
      expect(aiState.anomalies.first.transactionId, 'tx2');
      expect(aiState.healthScore, lessThan(100.0)); // health score drops
    });

    test('Chat Provider processes queries using local context', () async {
      final txNotifier = container.read(transactionProvider.notifier);
      final chatNotifier = container.read(chatProvider.notifier);

      // Verify initial chat state is empty
      expect(container.read(chatProvider), isEmpty);

      // Add context
      final tx = Transaction(
        id: 'tx1',
        amount: 300.0,
        merchant: 'Gourmet Food',
        category: 'Food',
        date: DateTime.now(),
        paymentMethod: 'Card',
        isRecurring: false,
      );
      await txNotifier.addTransaction(tx);

      // Send chat request
      await chatNotifier.sendQuery('Where am I spending the most?');

      final messages = container.read(chatProvider);
      expect(messages.length, 2); // User message + Bot message
      expect(messages[0].isUser, isTrue);
      expect(messages[0].text, 'Where am I spending the most?');
      expect(messages[1].isUser, isFalse);
      expect(messages[1].text, contains('Food'));
      expect(messages[1].text, contains('300.00'));
    });
  });
}
