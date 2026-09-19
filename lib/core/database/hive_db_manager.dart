import 'package:hive_flutter/hive_flutter.dart';
import '../../features/auth/data/models/user_session_model.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/budget/data/models/budget_model.dart';
import '../../features/goals/data/models/financial_goal_model.dart';
import '../../features/ai/data/models/anomaly_model.dart';
import '../../features/ai/data/models/insight_model.dart';
import '../../features/ai/data/models/chat_message_model.dart';
import '../../features/wallet/data/models/wallet_model.dart';

/// Central database manager to initialize and maintain Hive lifecycle, adapters, and boxes.
class HiveDbManager {
  static const String authBoxName = 'auth_box';
  static const String transactionsBoxName = 'transactions_box';
  static const String budgetBoxName = 'budget_box';
  static const String goalsBoxName = 'goals_box';
  static const String walletBoxName = 'wallet_box';

  /// Initializes Hive and registers the data model adapters.
  Future<void> init() async {
    await Hive.initFlutter();

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
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(WalletModelAdapter());
    }

    // Open boxes
    await openBoxes();
  }

  /// Opens all application data boxes.
  Future<void> openBoxes() async {
    await Hive.openBox<UserSessionModel>(authBoxName);
    await Hive.openBox<TransactionModel>(transactionsBoxName);
    await Hive.openBox<BudgetModel>(budgetBoxName);
    await Hive.openBox<FinancialGoalModel>(goalsBoxName);
    await Hive.openBox<WalletModel>(walletBoxName);
  }

  /// Box for auth session.
  Box<UserSessionModel> get authBox => Hive.box<UserSessionModel>(authBoxName);

  /// Box for storing transactions.
  Box<TransactionModel> get transactionsBox => Hive.box<TransactionModel>(transactionsBoxName);

  /// Box for budget category limits and tracking.
  Box<BudgetModel> get budgetBox => Hive.box<BudgetModel>(budgetBoxName);

  /// Box for storing financial goals.
  Box<FinancialGoalModel> get goalsBox => Hive.box<FinancialGoalModel>(goalsBoxName);

  /// Box for storing wallet balance.
  Box<WalletModel> get walletBox => Hive.box<WalletModel>(walletBoxName);
}
