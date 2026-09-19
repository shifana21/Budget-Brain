import '../entities/wallet.dart';

/// Repository interface for wallet operations.
abstract class WalletRepository {
  /// Gets the user's wallet. Returns null if no wallet exists.
  Future<Wallet?> getWallet();

  /// Saves or updates the wallet with the given balance.
  Future<void> saveWallet(double balance);

  /// Updates the wallet balance.
  Future<void> updateWallet(double balance);
}
