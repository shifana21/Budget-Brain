import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Use case for retrieving all transactions.
class GetTransactionsUseCase {
  final TransactionRepository _repository;

  GetTransactionsUseCase(this._repository);

  /// Executes the request to get all transactions.
  Future<List<Transaction>> call() {
    return _repository.getTransactions();
  }
}
