import '../entities/financial_goal.dart';

/// Use case for calculating the monthly savings requirement for a goal.
class CalculateGoalRequirementUseCase {
  /// Calculates the monthly saving amount required to reach the [goal].
  ///
  /// Optionally accepts [relativeTo] date (defaults to DateTime.now()).
  double call(FinancialGoal goal, {DateTime? relativeTo}) {
    final now = relativeTo ?? DateTime.now();
    final remainingAmount = goal.targetAmount - goal.currentAmount;

    if (remainingAmount <= 0) {
      return 0.0;
    }

    final difference = goal.targetDate.difference(now);
    final remainingDays = difference.inDays;

    if (remainingDays <= 0) {
      // Goal deadline has passed or is today, return remaining amount
      return remainingAmount;
    }

    // Convert days to approximate months (30.4 days per month)
    final remainingMonths = remainingDays / 30.4;

    if (remainingMonths < 1) {
      // If less than a month remains, return remaining amount as monthly requirement
      return remainingAmount;
    }

    return remainingAmount / remainingMonths;
  }
}
