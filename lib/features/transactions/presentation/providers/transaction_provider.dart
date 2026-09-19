import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../budget/presentation/providers/budget_provider.dart';

/// State notifier for managing transaction states.
class TransactionNotifier extends StateNotifier<List<Transaction>> {
  final TransactionRepository _repository;
  final Ref _ref;

  TransactionNotifier(this._repository, this._ref) : super([]) {
    loadTransactions();
  }

  /// Loads transactions from repository.
  Future<void> loadTransactions() async {
    state = await _repository.getTransactions();
  }

  /// Adds a new transaction and reloads the state.
  Future<void> addTransaction(Transaction transaction) async {
    await _repository.addTransaction(transaction);
    await loadTransactions();
    // Trigger budget spent amount sync for live AI recalculation
    await _ref.read(budgetProvider.notifier).syncSpentAmounts(state);
  }

  /// Deletes a transaction by [id] and reloads the state.
  Future<void> deleteTransaction(String id) async {
    await _repository.deleteTransaction(id);
    await loadTransactions();
    // Trigger budget spent amount sync for live AI recalculation
    await _ref.read(budgetProvider.notifier).syncSpentAmounts(state);
  }
}

/// Provider for [TransactionNotifier] exposing transaction list state.
/// Using keepAlive to prevent recreation when dependencies change.
final transactionProvider = StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionNotifier(repository, ref);
}, name: 'transactionProvider');
