import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/hive_db_manager.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/datasources/local_auth_data_source.dart';

import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/data/datasources/local_transaction_data_source.dart';

import '../../features/budget/domain/repositories/budget_repository.dart';
import '../../features/budget/data/repositories/budget_repository_impl.dart';
import '../../features/budget/data/datasources/local_budget_data_source.dart';

import '../../features/goals/domain/repositories/goal_repository.dart';
import '../../features/goals/data/repositories/goal_repository_impl.dart';
import '../../features/goals/data/datasources/local_goal_data_source.dart';

/// Provider exposing the central Hive Database Manager.
final dbManagerProvider = Provider<HiveDbManager>((ref) {
  throw UnimplementedError('dbManagerProvider must be overridden in ProviderScope');
});

/// Provider for AuthRepository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final db = ref.watch(dbManagerProvider);
  return AuthRepositoryImpl(LocalAuthDataSourceImpl(db.authBox));
});

/// Provider for TransactionRepository.
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.watch(dbManagerProvider);
  return TransactionRepositoryImpl(LocalTransactionDataSourceImpl(db.transactionsBox));
});

/// Provider for BudgetRepository.
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final db = ref.watch(dbManagerProvider);
  return BudgetRepositoryImpl(LocalBudgetDataSourceImpl(db.budgetBox));
});

/// Provider for GoalRepository.
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final db = ref.watch(dbManagerProvider);
  return GoalRepositoryImpl(LocalGoalDataSourceImpl(db.goalsBox));
});
