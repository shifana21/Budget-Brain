import 'package:hive/hive.dart';
import '../../domain/entities/transaction.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
class TransactionModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String merchant;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String paymentMethod;

  @HiveField(6)
  final bool isRecurring;

  @HiveField(7)
  final String? notes;

  const TransactionModel({
    required this.id,
    required this.amount,
    required this.merchant,
    required this.category,
    required this.date,
    required this.paymentMethod,
    required this.isRecurring,
    this.notes,
  });

  Transaction toEntity() {
    return Transaction(
      id: id,
      amount: amount,
      merchant: merchant,
      category: category,
      date: date,
      paymentMethod: paymentMethod,
      isRecurring: isRecurring,
      notes: notes,
    );
  }

  factory TransactionModel.fromEntity(Transaction entity) {
    return TransactionModel(
      id: entity.id,
      amount: entity.amount,
      merchant: entity.merchant,
      category: entity.category,
      date: entity.date,
      paymentMethod: entity.paymentMethod,
      isRecurring: entity.isRecurring,
      notes: entity.notes,
    );
  }
}
