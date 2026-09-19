import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/local_wallet_data_source.dart';
import '../models/wallet_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  final LocalWalletDataSource localDataSource;

  WalletRepositoryImpl(this.localDataSource);

  @override
  Future<Wallet?> getWallet() async {
    try {
      final walletModel = await localDataSource.getWallet();
      if (walletModel == null) return null;
      return walletModel.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveWallet(double balance) async {
    try {
      final walletModel = WalletModel(initialBalance: balance);
      await localDataSource.saveWallet(walletModel);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateWallet(double balance) async {
    try {
      final walletModel = WalletModel(initialBalance: balance);
      await localDataSource.updateWallet(walletModel);
    } catch (e) {
      rethrow;
    }
  }
}
