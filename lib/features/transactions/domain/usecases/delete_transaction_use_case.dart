import '../repositories/transaction_repository.dart';

/// Use case for deleting a transaction.
class DeleteTransactionUseCase {
  final TransactionRepository _repository;

  DeleteTransactionUseCase(this._repository);

  /// Executes the request to delete a transaction by its [id].
  Future<void> call(String id) {
    return _repository.deleteTransaction(id);
  }
}
