import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:budget_brain/core/database/hive_db_manager.dart';
import 'package:budget_brain/features/transactions/data/models/transaction_model.dart';
import 'package:budget_brain/features/transactions/data/datasources/local_transaction_data_source.dart';
import 'package:budget_brain/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:budget_brain/features/transactions/domain/entities/transaction.dart';

void main() {
  late Directory tempDir;
  late HiveDbManager dbManager;
  late LocalTransactionDataSourceImpl dataSource;
  late TransactionRepositoryImpl repository;

  setUp(() async {
    // Setup temporary directory for Hive test storage
    tempDir = await Directory.systemTemp.createTemp('hive_test_dir');
    Hive.init(tempDir.path);

    // Register Hive Adapters
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }

    // Open boxes
    await Hive.openBox<TransactionModel>('transactions_box');

    // Initialize db manager
    dbManager = HiveDbManager();
    dataSource = LocalTransactionDataSourceImpl(dbManager.transactionsBox);
    repository = TransactionRepositoryImpl(dataSource);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('Add multiple transactions and verify all are stored', () async {
    // Clear any existing transactions
    final existing = await dataSource.getTransactions();
    for (final tx in existing) {
      await dataSource.deleteTransaction(tx.id);
    }

    // Add first transaction - Food ₹200
    final tx1 = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: 200.0,
      merchant: 'Restaurant',
      category: 'Food',
      date: DateTime.now(),
      paymentMethod: 'Card',
      isRecurring: false,
    );
    await repository.addTransaction(tx1);

    // Verify first transaction
    var transactions = await repository.getTransactions();
    expect(transactions.length, 1);
    expect(transactions.first.amount, 200.0);

    // Add second transaction - Travel ₹500
    final tx2 = Transaction(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      amount: 500.0,
      merchant: 'Uber',
      category: 'Travel',
      date: DateTime.now(),
      paymentMethod: 'UPI',
      isRecurring: false,
    );
    await repository.addTransaction(tx2);

    // Verify second transaction
    transactions = await repository.getTransactions();
    expect(transactions.length, 2);
    expect(transactions.any((t) => t.amount == 200.0), true);
    expect(transactions.any((t) => t.amount == 500.0), true);

    // Add third transaction - Shopping ₹1000
    final tx3 = Transaction(
      id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
      amount: 1000.0,
      merchant: 'Amazon',
      category: 'Shopping',
      date: DateTime.now(),
      paymentMethod: 'Card',
      isRecurring: false,
    );
    await repository.addTransaction(tx3);

    // Verify third transaction
    transactions = await repository.getTransactions();
    expect(transactions.length, 3);
    expect(transactions.any((t) => t.amount == 200.0), true);
    expect(transactions.any((t) => t.amount == 500.0), true);
    expect(transactions.any((t) => t.amount == 1000.0), true);

    // Verify all IDs are unique
    final ids = transactions.map((t) => t.id).toSet();
    expect(ids.length, 3);
  });

  test('Verify Hive box stores multiple transactions correctly', () async {
    // Clear any existing transactions
    final existing = await dataSource.getTransactions();
    for (final tx in existing) {
      await dataSource.deleteTransaction(tx.id);
    }

    // Add transactions directly to Hive box
    final model1 = TransactionModel(
      id: 'test_1',
      amount: 200.0,
      merchant: 'Restaurant',
      category: 'Food',
      date: DateTime.now(),
      paymentMethod: 'Card',
      isRecurring: false,
    );
    await dataSource.addTransaction(model1);

    final model2 = TransactionModel(
      id: 'test_2',
      amount: 500.0,
      merchant: 'Uber',
      category: 'Travel',
      date: DateTime.now(),
      paymentMethod: 'UPI',
      isRecurring: false,
    );
    await dataSource.addTransaction(model2);

    final model3 = TransactionModel(
      id: 'test_3',
      amount: 1000.0,
      merchant: 'Amazon',
      category: 'Shopping',
      date: DateTime.now(),
      paymentMethod: 'Card',
      isRecurring: false,
    );
    await dataSource.addTransaction(model3);

    // Verify all are stored
    final stored = await dataSource.getTransactions();
    expect(stored.length, 3);
  });
}
