/// Represents a monthly budget for a specific category.
class Budget {
  final String category;
  final double monthlyLimit;
  final double spentAmount;

  const Budget({
    required this.category,
    required this.monthlyLimit,
    required this.spentAmount,
  });
}
