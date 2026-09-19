import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

/// Data source interface for local transaction database operations.
abstract class LocalTransactionDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
}

/// Hive implementation of [LocalTransactionDataSource].
class LocalTransactionDataSourceImpl implements LocalTransactionDataSource {
  final Box<TransactionModel> _box;

  LocalTransactionDataSourceImpl(this._box);

  @override
  Future<List<TransactionModel>> getTransactions() async {
    return _box.values.toList();
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
  }
}
