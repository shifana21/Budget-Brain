import 'package:flutter_test/flutter_test.dart';

// Import all Domain Entities
import 'package:budget_brain/features/auth/domain/entities/user_session.dart';
import 'package:budget_brain/features/transactions/domain/entities/transaction.dart';
import 'package:budget_brain/features/budget/domain/entities/budget.dart';
import 'package:budget_brain/features/goals/domain/entities/financial_goal.dart';
import 'package:budget_brain/features/ai/domain/entities/anomaly.dart';
import 'package:budget_brain/features/ai/domain/entities/insight.dart';
import 'package:budget_brain/features/ai/domain/entities/chat_message.dart';

// Import all Repositories
import 'package:budget_brain/features/auth/domain/repositories/auth_repository.dart';
import 'package:budget_brain/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:budget_brain/features/budget/domain/repositories/budget_repository.dart';
import 'package:budget_brain/features/goals/domain/repositories/goal_repository.dart';
import 'package:budget_brain/features/ai/domain/repositories/ai_repository.dart';

// Import all Use Cases
import 'package:budget_brain/features/auth/domain/usecases/login_use_case.dart';
import 'package:budget_brain/features/auth/domain/usecases/signup_use_case.dart';
import 'package:budget_brain/features/auth/domain/usecases/get_session_use_case.dart';

import 'package:budget_brain/features/transactions/domain/usecases/add_transaction_use_case.dart';
import 'package:budget_brain/features/transactions/domain/usecases/get_transactions_use_case.dart';
import 'package:budget_brain/features/transactions/domain/usecases/delete_transaction_use_case.dart';

import 'package:budget_brain/features/goals/domain/usecases/update_goal_progress_use_case.dart';
import 'package:budget_brain/features/goals/domain/usecases/calculate_goal_requirement_use_case.dart';

import 'package:budget_brain/features/ai/domain/usecases/predict_expenses_use_case.dart';
import 'package:budget_brain/features/ai/domain/usecases/detect_anomalies_use_case.dart';
import 'package:budget_brain/features/ai/domain/usecases/analyze_financial_health_use_case.dart';
import 'package:budget_brain/features/ai/domain/usecases/generate_insights_use_case.dart';
import 'package:budget_brain/features/ai/domain/usecases/process_chat_query_use_case.dart';

// Mock/Stub Repository Implementations for Verification
class MockAuthRepository implements AuthRepository {
  @override
  Future<UserSession> login(String email, String password) async {
    return const UserSession(userId: '1', username: 'test', email: 'test@example.com', isGuest: false);
  }

  @override
  Future<UserSession> signup(String username, String email, String password) async {
    return const UserSession(userId: '1', username: 'test', email: 'test@example.com', isGuest: false);
  }

  @override
  Future<UserSession?> getSession() async {
    return null;
  }

  @override
  Future<void> logout() async {}
}

class MockTransactionRepository implements TransactionRepository {
  @override
  Future<List<Transaction>> getTransactions() async => [];
  @override
  Future<void> addTransaction(Transaction transaction) async {}
  @override
  Future<void> deleteTransaction(String id) async {}
}

class MockBudgetRepository implements BudgetRepository {
  @override
  Future<List<Budget>> getBudgets() async => [];
  @override
  Future<void> updateBudgetLimit(String category, double limit) async {}
  @override
  Future<Budget?> getBudgetForCategory(String category) async => null;
  @override
  Future<void> syncSpentAmounts(List<Transaction> transactions) async {}
}

class MockGoalRepository implements GoalRepository {
  @override
  Future<List<FinancialGoal>> getGoals() async => [];
  @override
  Future<void> addGoal(FinancialGoal goal) async {}
  @override
  Future<void> updateGoalProgress(String id, double currentAmount) async {}
  @override
  Future<void> deleteGoal(String id) async {}
}

class MockAIRepository implements AIRepository {
  @override
  Future<Map<String, double>> predictExpenses() async => {};
  @override
  Future<List<Anomaly>> detectAnomalies() async => [];
  @override
  Future<String> analyzeFinancialHealth() async => 'Good';
  @override
  Future<List<Insight>> generateInsights() async => [];
  @override
  Future<ChatMessage> processChatQuery(String query) async {
    return ChatMessage(id: '1', text: 'Reply', isUser: false, timestamp: DateTime.now());
  }
}

void main() {
  group('Domain Layer Compilation Tests', () {
    late MockAuthRepository mockAuthRepository;
    late MockTransactionRepository mockTransactionRepository;
    late MockGoalRepository mockGoalRepository;
    late MockAIRepository mockAIRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockTransactionRepository = MockTransactionRepository();
      mockGoalRepository = MockGoalRepository();
      mockAIRepository = MockAIRepository();
    });

    test('Verify UseCase Instantiations and Mock Executions', () async {
      // Auth UseCases
      final loginUseCase = LoginUseCase(mockAuthRepository);
      final signupUseCase = SignupUseCase(mockAuthRepository);
      final getSessionUseCase = GetSessionUseCase(mockAuthRepository);

      final session = await loginUseCase('test@example.com', 'password');
      expect(session.userId, '1');
      expect(session.username, 'test');
      expect(session.email, 'test@example.com');
      expect(session.isGuest, false);

      final signupSession = await signupUseCase('test', 'test@example.com', 'password');
      expect(signupSession.userId, '1');

      final currentSession = await getSessionUseCase();
      expect(currentSession, isNull);

      // Transaction UseCases
      final addTransactionUseCase = AddTransactionUseCase(mockTransactionRepository);
      final getTransactionsUseCase = GetTransactionsUseCase(mockTransactionRepository);
      final deleteTransactionUseCase = DeleteTransactionUseCase(mockTransactionRepository);

      await addTransactionUseCase(Transaction(
        id: 't1',
        amount: 25.0,
        merchant: 'Coffee Shop',
        category: 'Food',
        date: DateTime.now(),
        paymentMethod: 'Credit Card',
        isRecurring: false,
      ));
      final txs = await getTransactionsUseCase();
      expect(txs, isEmpty);
      await deleteTransactionUseCase('t1');

      // AI UseCases
      final predictExpensesUseCase = PredictExpensesUseCase(mockAIRepository);
      final detectAnomaliesUseCase = DetectAnomaliesUseCase(mockAIRepository);
      final analyzeFinancialHealthUseCase = AnalyzeFinancialHealthUseCase(mockAIRepository);
      final generateInsightsUseCase = GenerateInsightsUseCase(mockAIRepository);
      final processChatQueryUseCase = ProcessChatQueryUseCase(mockAIRepository);

      expect(await predictExpensesUseCase(), isEmpty);
      expect(await detectAnomaliesUseCase(), isEmpty);
      expect(await analyzeFinancialHealthUseCase(), 'Good');
      expect(await generateInsightsUseCase(), isEmpty);

      final reply = await processChatQueryUseCase('Hello');
      expect(reply.text, 'Reply');
      expect(reply.isUser, false);

      // Goals UseCases
      final updateGoalProgressUseCase = UpdateGoalProgressUseCase(mockGoalRepository);
      final calculateGoalRequirementUseCase = CalculateGoalRequirementUseCase();

      await updateGoalProgressUseCase('g1', 500.0);

      // Test CalculateGoalRequirementUseCase
      final goal = FinancialGoal(
        id: 'g1',
        name: 'Emergency Fund',
        targetAmount: 1200.0,
        currentAmount: 200.0,
        targetDate: DateTime.now().add(const Duration(days: 365)), // 12 months roughly
      );

      final monthlySaving = calculateGoalRequirementUseCase(goal);
      // Remaining target: 1000. 365 days / 30.4 days/mo ~ 12 months. Monthly requirement should be ~ 1000 / 12 ~ 83.33
      expect(monthlySaving, closeTo(83.33, 1.0));
    });
  });
}
