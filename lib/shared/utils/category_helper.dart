import '../../features/transactions/domain/entities/transaction.dart';

/// Default expense categories for the presentation layer.
abstract final class ExpenseCategories {
  static const all = [
    'Food',
    'Transport',
    'Shopping',
    'Utilities',
    'Entertainment',
    'Health',
    'Education',
    'Travel',
    'Other',
  ];
}

/// Suggests a category from merchant name using prior transaction history.
String? suggestCategoryFromHistory(String merchant, List<Transaction> transactions) {
  if (merchant.trim().isEmpty) return null;

  final normalized = merchant.trim().toLowerCase();

  for (final tx in transactions) {
    if (tx.merchant.toLowerCase() == normalized) {
      return tx.category;
    }
  }

  for (final tx in transactions) {
    final m = tx.merchant.toLowerCase();
    if (m.contains(normalized) || normalized.contains(m)) {
      return tx.category;
    }
  }

  return null;
}
