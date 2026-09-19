import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../data/datasources/local_wallet_data_source.dart';
import '../../../../core/providers/core_providers.dart';

/// Provider for the wallet repository.
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  try {
    final dbManager = ref.watch(dbManagerProvider);
    final dataSource = LocalWalletDataSourceImpl(dbManager.walletBox);
    return WalletRepositoryImpl(dataSource);
  } catch (e) {
    // Return a fallback repository that handles errors gracefully
    return _FallbackWalletRepository();
  }
});

/// Provider for the wallet state.
final walletProvider = StateNotifierProvider<WalletNotifier, Wallet?>((ref) {
  final repository = ref.watch(walletRepositoryProvider);
  return WalletNotifier(repository);
});

/// Notifier for managing wallet state.
class WalletNotifier extends StateNotifier<Wallet?> {
  final WalletRepository _repository;

  WalletNotifier(this._repository) : super(null) {
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      final wallet = await _repository.getWallet();
      state = wallet;
    } catch (e) {
      state = null;
    }
  }

  Future<void> saveWallet(double balance) async {
    await _repository.saveWallet(balance);
    state = Wallet(initialBalance: balance);
  }

  Future<void> updateWallet(double balance) async {
    await _repository.updateWallet(balance);
    state = Wallet(initialBalance: balance);
  }
}

/// Fallback repository for handling initialization errors gracefully.
class _FallbackWalletRepository implements WalletRepository {
  @override
  Future<Wallet?> getWallet() async => null;

  @override
  Future<void> saveWallet(double balance) async {}

  @override
  Future<void> updateWallet(double balance) async {}
}
