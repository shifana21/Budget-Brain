import 'package:hive/hive.dart';
import '../../domain/entities/anomaly.dart';

part 'anomaly_model.g.dart';

@HiveType(typeId: 4)
class AnomalyModel extends Anomaly {
  const AnomalyModel({
    required super.transactionId,
    required super.riskLevel,
    required super.message,
  });

  @HiveField(0)
  @override
  String get transactionId => super.transactionId;

  @HiveField(1)
  @override
  String get riskLevel => super.riskLevel;

  @HiveField(2)
  @override
  String get message => super.message;

  factory AnomalyModel.fromEntity(Anomaly entity) {
    return AnomalyModel(
      transactionId: entity.transactionId,
      riskLevel: entity.riskLevel,
      message: entity.message,
    );
  }
}
