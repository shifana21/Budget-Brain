import 'package:hive/hive.dart';
import '../models/wallet_model.dart';

abstract class LocalWalletDataSource {
  Future<WalletModel?> getWallet();
  Future<void> saveWallet(WalletModel wallet);
  Future<void> updateWallet(WalletModel wallet);
}

class LocalWalletDataSourceImpl implements LocalWalletDataSource {
  final Box<WalletModel> _walletBox;

  LocalWalletDataSourceImpl(this._walletBox);

  @override
  Future<WalletModel?> getWallet() async {
    return _walletBox.get('wallet');
  }

  @override
  Future<void> saveWallet(WalletModel wallet) async {
    await _walletBox.put('wallet', wallet);
  }

  @override
  Future<void> updateWallet(WalletModel wallet) async {
    await _walletBox.put('wallet', wallet);
  }
}
