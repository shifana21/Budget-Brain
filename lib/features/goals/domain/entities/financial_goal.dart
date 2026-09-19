/// Represents a saving or investing goal set by the user.
class FinancialGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;

  const FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
  });
}
