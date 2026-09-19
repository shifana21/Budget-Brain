import '../entities/transaction.dart';

/// Contract defining transaction operations.
abstract class TransactionRepository {
  /// Retrieves a list of all transactions.
  Future<List<Transaction>> getTransactions();

  /// Adds a new transaction.
  Future<void> addTransaction(Transaction transaction);

  /// Deletes a transaction by its unique [id].
  Future<void> deleteTransaction(String id);
}
