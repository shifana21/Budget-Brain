/// Model for calculator results
class CalculationResult {
  final String label;
  final double value;
  final String? unit;

  CalculationResult({
    required this.label,
    required this.value,
    this.unit,
  });
}
