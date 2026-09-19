import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local_transaction_data_source.dart';
import '../models/transaction_model.dart';

/// Implementation of the [TransactionRepository] contract.
class TransactionRepositoryImpl implements TransactionRepository {
  final LocalTransactionDataSource _localDataSource;

  TransactionRepositoryImpl(this._localDataSource);

  @override
  Future<List<Transaction>> getTransactions() async {
    final models = await _localDataSource.getTransactions();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    await _localDataSource.addTransaction(model);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _localDataSource.deleteTransaction(id);
  }
}
