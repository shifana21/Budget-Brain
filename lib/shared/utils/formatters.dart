import 'package:intl/intl.dart';

/// Presentation-layer formatting helpers.
abstract final class AppFormatters {
  static final currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );
  static final compactCurrency = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '₹',
  );
  static final date = DateFormat('MMM d, yyyy');
  static final shortDate = DateFormat('MMM d');
  static final monthYear = DateFormat('MMM yyyy');
  static final time = DateFormat('h:mm a');
}
