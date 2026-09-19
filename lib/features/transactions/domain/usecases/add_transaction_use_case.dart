import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Use case for adding a new transaction.
class AddTransactionUseCase {
  final TransactionRepository _repository;

  AddTransactionUseCase(this._repository);

  /// Executes the add transaction request.
  Future<void> call(Transaction transaction) {
    return _repository.addTransaction(transaction);
  }
}
