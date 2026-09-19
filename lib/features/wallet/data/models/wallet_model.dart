import 'package:hive/hive.dart';
import '../../domain/entities/wallet.dart';

part 'wallet_model.g.dart';

@HiveType(typeId: 7)
class WalletModel {
  @HiveField(0)
  final double initialBalance;

  WalletModel({
    required this.initialBalance,
  });

  factory WalletModel.fromEntity(Wallet wallet) {
    return WalletModel(
      initialBalance: wallet.initialBalance,
    );
  }

  Wallet toEntity() {
    return Wallet(
      initialBalance: initialBalance,
    );
  }

  WalletModel copyWith({
    double? initialBalance,
  }) {
    return WalletModel(
      initialBalance: initialBalance ?? this.initialBalance,
    );
  }
}
