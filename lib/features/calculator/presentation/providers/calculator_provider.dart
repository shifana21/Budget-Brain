import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/calculation_result.dart';

/// Calculator state for different calculators
class CalculatorState {
  // Basic Calculator
  String display = '0';
  String? previousValue;
  String? operation;
  bool shouldResetDisplay = false;

  // Savings Calculator
  double currentSavings = 0.0;
  double monthlyContribution = 0.0;
  int months = 12;

  // Goal Calculator
  double goalAmount = 0.0;
  double currentAmount = 0.0;
  int monthsRemaining = 12;

  // EMI Calculator
  double loanAmount = 0.0;
  double interestRate = 0.0;
  int tenureMonths = 12;

  // Expense Split Calculator
  double totalExpense = 0.0;
  int numberOfPeople = 2;

  // Budget Allocation Calculator
  double monthlyIncome = 0.0;

  CalculatorState();

  CalculatorState copyWith({
    String? display,
    String? previousValue,
    String? operation,
    bool? shouldResetDisplay,
    double? currentSavings,
    double? monthlyContribution,
    int? months,
    double? goalAmount,
    double? currentAmount,
    int? monthsRemaining,
    double? loanAmount,
    double? interestRate,
    int? tenureMonths,
    double? totalExpense,
    int? numberOfPeople,
    double? monthlyIncome,
  }) {
    return CalculatorState()
      ..display = display ?? this.display
      ..previousValue = previousValue ?? this.previousValue
      ..operation = operation ?? this.operation
      ..shouldResetDisplay = shouldResetDisplay ?? this.shouldResetDisplay
      ..currentSavings = currentSavings ?? this.currentSavings
      ..monthlyContribution = monthlyContribution ?? this.monthlyContribution
      ..months = months ?? this.months
      ..goalAmount = goalAmount ?? this.goalAmount
      ..currentAmount = currentAmount ?? this.currentAmount
      ..monthsRemaining = monthsRemaining ?? this.monthsRemaining
      ..loanAmount = loanAmount ?? this.loanAmount
      ..interestRate = interestRate ?? this.interestRate
      ..tenureMonths = tenureMonths ?? this.tenureMonths
      ..totalExpense = totalExpense ?? this.totalExpense
      ..numberOfPeople = numberOfPeople ?? this.numberOfPeople
      ..monthlyIncome = monthlyIncome ?? this.monthlyIncome;
  }
}

/// Calculator state notifier
class CalculatorNotifier extends StateNotifier<CalculatorState> {
  CalculatorNotifier() : super(CalculatorState());

  // Basic Calculator Methods
  void inputNumber(String number) {
    if (state.shouldResetDisplay) {
      state.display = number;
      state.shouldResetDisplay = false;
    } else {
      if (state.display == '0' && number != '.') {
        state.display = number;
      } else if (number == '.' && state.display.contains('.')) {
        return;
      } else {
        state.display += number;
      }
    }
    state = state.copyWith();
  }

  void inputOperation(String op) {
    state.previousValue = state.display;
    state.operation = op;
    state.shouldResetDisplay = true;
    state = state.copyWith();
  }

  void calculate() {
    if (state.previousValue == null || state.operation == null) return;

    final prev = double.parse(state.previousValue!);
    final current = double.parse(state.display);
    double result = 0.0;

    switch (state.operation) {
      case '+':
        result = prev + current;
        break;
      case '-':
        result = prev - current;
        break;
      case '×':
        result = prev * current;
        break;
      case '÷':
        result = current != 0 ? prev / current : 0.0;
        break;
      case '%':
        result = prev % current;
        break;
    }

    state.display = result.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
    state.previousValue = null;
    state.operation = null;
    state.shouldResetDisplay = true;
    state = state.copyWith();
  }

  void clear() {
    state.display = '0';
    state.previousValue = null;
    state.operation = null;
    state.shouldResetDisplay = false;
    state = state.copyWith();
  }

  void backspace() {
    if (state.display.length > 1) {
      state.display = state.display.substring(0, state.display.length - 1);
    } else {
      state.display = '0';
    }
    state = state.copyWith();
  }

  // Savings Calculator Methods
  void updateCurrentSavings(double value) {
    state.currentSavings = value;
    state = state.copyWith();
  }

  void updateMonthlyContribution(double value) {
    state.monthlyContribution = value;
    state = state.copyWith();
  }

  void updateMonths(int value) {
    state.months = value;
    state = state.copyWith();
  }

  CalculationResult calculateFutureSavings() {
    final futureSavings =
        state.currentSavings + (state.monthlyContribution * state.months);
    return CalculationResult(
      label: 'Future Savings',
      value: futureSavings,
      unit: '₹',
    );
  }

  // Goal Calculator Methods
  void updateGoalAmount(double value) {
    state.goalAmount = value;
    state = state.copyWith();
  }

  void updateCurrentAmount(double value) {
    state.currentAmount = value;
    state = state.copyWith();
  }

  void updateMonthsRemaining(int value) {
    state.monthsRemaining = value;
    state = state.copyWith();
  }

  CalculationResult calculateRequiredMonthlySavings() {
    if (state.monthsRemaining <= 0) {
      return CalculationResult(
        label: 'Required Monthly Savings',
        value: 0.0,
        unit: '₹',
      );
    }
    final required =
        (state.goalAmount - state.currentAmount) / state.monthsRemaining;
    return CalculationResult(
      label: 'Required Monthly Savings',
      value: required,
      unit: '₹',
    );
  }

  // EMI Calculator Methods
  void updateLoanAmount(double value) {
    state.loanAmount = value;
    state = state.copyWith();
  }

  void updateInterestRate(double value) {
    state.interestRate = value;
    state = state.copyWith();
  }

  void updateTenureMonths(int value) {
    state.tenureMonths = value;
    state = state.copyWith();
  }

  CalculationResult calculateEMI() {
    if (state.loanAmount <= 0 ||
        state.interestRate <= 0 ||
        state.tenureMonths <= 0) {
      return CalculationResult(label: 'Monthly EMI', value: 0.0, unit: '₹');
    }
    final monthlyRate = state.interestRate / 12 / 100;

    // Calculate power manually
    double factor = 1.0;
    for (int i = 0; i < state.tenureMonths; i++) {
      factor *= (1 + monthlyRate);
    }

    final numerator = state.loanAmount * monthlyRate * factor;
    final denominator = factor - 1;
    final emi = numerator / denominator;

    return CalculationResult(label: 'Monthly EMI', value: emi, unit: '₹');
  }

  // Expense Split Calculator Methods
  void updateTotalExpense(double value) {
    state.totalExpense = value;
    state = state.copyWith();
  }

  void updateNumberOfPeople(int value) {
    state.numberOfPeople = value > 0 ? value : 1;
    state = state.copyWith();
  }

  CalculationResult calculateExpensePerPerson() {
    if (state.numberOfPeople <= 0) {
      return CalculationResult(
        label: 'Amount Per Person',
        value: 0.0,
        unit: '₹',
      );
    }
    final perPerson = state.totalExpense / state.numberOfPeople;
    return CalculationResult(
      label: 'Amount Per Person',
      value: perPerson,
      unit: '₹',
    );
  }

  // Budget Allocation Calculator Methods
  void updateMonthlyIncome(double value) {
    state.monthlyIncome = value;
    state = state.copyWith();
  }

  List<CalculationResult> calculateBudgetAllocation() {
    final needs = state.monthlyIncome * 0.50;
    final wants = state.monthlyIncome * 0.30;
    final savings = state.monthlyIncome * 0.20;

    return [
      CalculationResult(label: 'Needs (50%)', value: needs, unit: '₹'),
      CalculationResult(label: 'Wants (30%)', value: wants, unit: '₹'),
      CalculationResult(label: 'Savings (20%)', value: savings, unit: '₹'),
    ];
  }
}

/// Calculator provider
final calculatorProvider =
    StateNotifierProvider<CalculatorNotifier, CalculatorState>((ref) {
      return CalculatorNotifier();
    });
