/// Wallet entity representing user's financial balance.
class Wallet {
  final double initialBalance;

  const Wallet({
    required this.initialBalance,
  });

  Wallet copyWith({
    double? initialBalance,
  }) {
    return Wallet(
      initialBalance: initialBalance ?? this.initialBalance,
    );
  }
}
