/// Represents a single financial transaction.
class Transaction {
  final String id;
  final double amount;
  final String merchant;
  final String category;
  final DateTime date;
  final String paymentMethod;
  final bool isRecurring;
  final String? notes;

  const Transaction({
    required this.id,
    required this.amount,
    required this.merchant,
    required this.category,
    required this.date,
    required this.paymentMethod,
    required this.isRecurring,
    this.notes,
  });
}
