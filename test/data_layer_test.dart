import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

// Imports
import 'package:budget_brain/core/database/hive_db_manager.dart';

import 'package:budget_brain/features/auth/data/models/user_session_model.dart';
import 'package:budget_brain/features/auth/data/datasources/local_auth_data_source.dart';
import 'package:budget_brain/features/auth/data/repositories/auth_repository_impl.dart';

import 'package:budget_brain/features/transactions/data/models/transaction_model.dart';
import 'package:budget_brain/features/transactions/domain/entities/transaction.dart';
import 'package:budget_brain/features/transactions/data/datasources/local_transaction_data_source.dart';
import 'package:budget_brain/features/transactions/data/repositories/transaction_repository_impl.dart';

import 'package:budget_brain/features/budget/data/models/budget_model.dart';
import 'package:budget_brain/features/budget/data/datasources/local_budget_data_source.dart';
import 'package:budget_brain/features/budget/data/repositories/budget_repository_impl.dart';

import 'package:budget_brain/features/goals/data/models/financial_goal_model.dart';
import 'package:budget_brain/features/goals/data/datasources/local_goal_data_source.dart';
import 'package:budget_brain/features/goals/data/repositories/goal_repository_impl.dart';

import 'package:budget_brain/features/ai/data/repositories/ai_repository_impl.dart';
import 'package:budget_brain/features/ai/data/models/anomaly_model.dart';
import 'package:budget_brain/features/ai/data/models/insight_model.dart';
import 'package:budget_brain/features/ai/data/models/chat_message_model.dart';

void main() {
  late Directory tempDir;
  late HiveDbManager dbManager;

  setUp(() async {
    // Setup temporary directory for Hive test storage
    tempDir = await Directory.systemTemp.createTemp('hive_test_dir');
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
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Data Layer CRUD Tests', () {
    test('Auth local data source & repository CRUD', () async {
      final localAuthDataSource = LocalAuthDataSourceImpl(dbManager.authBox);
      final authRepository = AuthRepositoryImpl(localAuthDataSource);

      // Verify initial session is null
      expect(await authRepository.getSession(), isNull);

      // Login mock
      final session = await authRepository.login('alice@example.com', 'password');
      expect(session.email, 'alice@example.com');
      expect(session.username, 'alice');

      // Verify session persisted
      final activeSession = await authRepository.getSession();
      expect(activeSession, isNotNull);
      expect(activeSession!.email, 'alice@example.com');

      // Logout
      await authRepository.logout();
      expect(await authRepository.getSession(), isNull);
    });

    test('Transactions local data source & repository CRUD', () async {
      final localTransactionDataSource = LocalTransactionDataSourceImpl(dbManager.transactionsBox);
      final transactionRepository = TransactionRepositoryImpl(localTransactionDataSource);

      // Verify initial list is empty
      expect(await transactionRepository.getTransactions(), isEmpty);

      // Add transaction
      final tx = Transaction(
        id: 'tx1',
        amount: 250.50,
        merchant: 'Supermarket',
        category: 'Groceries',
        date: DateTime(2026, 6, 13),
        paymentMethod: 'Debit Card',
        isRecurring: false,
        notes: 'Weekly haul',
      );
      await transactionRepository.addTransaction(tx);

      // Verify transaction added
      final list = await transactionRepository.getTransactions();
      expect(list.length, 1);
      expect(list.first.id, 'tx1');
      expect(list.first.merchant, 'Supermarket');

      // Delete transaction
      await transactionRepository.deleteTransaction('tx1');
      expect(await transactionRepository.getTransactions(), isEmpty);
    });

    test('Budget local data source & repository CRUD', () async {
      final localBudgetDataSource = LocalBudgetDataSourceImpl(dbManager.budgetBox);
      final budgetRepository = BudgetRepositoryImpl(localBudgetDataSource);

      // Verify initial list is empty
      expect(await budgetRepository.getBudgets(), isEmpty);

      // Update budget limit (creates new budget)
      await budgetRepository.updateBudgetLimit('Entertainment', 300.0);

      // Verify budget created
      var budget = await budgetRepository.getBudgetForCategory('Entertainment');
      expect(budget, isNotNull);
      expect(budget!.monthlyLimit, 300.0);
      expect(budget.spentAmount, 0.0);

      // Update budget limit again (updates existing limit)
      await budgetRepository.updateBudgetLimit('Entertainment', 400.0);
      budget = await budgetRepository.getBudgetForCategory('Entertainment');
      expect(budget!.monthlyLimit, 400.0);
    });

    test('Goals local data source & repository CRUD', () async {
      final localGoalDataSource = LocalGoalDataSourceImpl(dbManager.goalsBox);
      final goalRepository = GoalRepositoryImpl(localGoalDataSource);

      // Verify initial list is empty
      expect(await goalRepository.getGoals(), isEmpty);

      // Add Goal
      final goal = FinancialGoalModel(
        id: 'goal1',
        name: 'New Laptop',
        targetAmount: 1500.0,
        currentAmount: 100.0,
        targetDate: DateTime(2026, 12, 31),
      );
      await goalRepository.addGoal(goal);

      // Verify Goal added
      var list = await goalRepository.getGoals();
      expect(list.length, 1);
      expect(list.first.name, 'New Laptop');

      // Update progress
      await goalRepository.updateGoalProgress('goal1', 500.0);
      list = await goalRepository.getGoals();
      expect(list.first.currentAmount, 500.0);

      // Delete Goal
      await goalRepository.deleteGoal('goal1');
      expect(await goalRepository.getGoals(), isEmpty);
    });

    test('AI Repository with local transaction dependency checks', () async {
      final localTransactionDataSource = LocalTransactionDataSourceImpl(dbManager.transactionsBox);
      final aiRepository = AIRepositoryImpl(localTransactionDataSource);

      // Add a large transaction (> 1000) to trigger anomaly and high spending
      final tx = TransactionModel(
        id: 'tx_large',
        amount: 6000.0,
        merchant: 'Tech Shop',
        category: 'Electronics',
        date: DateTime.now(),
        paymentMethod: 'Wire',
        isRecurring: false,
      );
      await localTransactionDataSource.addTransaction(tx);

      // Verify anomaly detected
      final anomalies = await aiRepository.detectAnomalies();
      expect(anomalies.length, 1);
      expect(anomalies.first.transactionId, 'tx_large');
      expect(anomalies.first.riskLevel, 'High');

      // Verify health analysis reacts to spending
      final health = await aiRepository.analyzeFinancialHealth();
      expect(health, contains('Your monthly spending is high'));

      // Verify predictions calculate properly
      final predictions = await aiRepository.predictExpenses();
      expect(predictions['Electronics'], closeTo(6600.0, 0.1)); // 6000 * 1.1

      // Verify insights generate
      final insights = await aiRepository.generateInsights();
      expect(insights, isNotEmpty);

      // Verify chat queries
      final response = await aiRepository.processChatQuery('Tell me about budget');
      expect(response.text, contains('You can set and monitor monthly budgets'));
    });
  });
}
