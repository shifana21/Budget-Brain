import 'package:hive/hive.dart';
import '../../domain/entities/financial_goal.dart';

part 'financial_goal_model.g.dart';

@HiveType(typeId: 3)
class FinancialGoalModel extends FinancialGoal {
  const FinancialGoalModel({
    required super.id,
    required super.name,
    required super.targetAmount,
    required super.currentAmount,
    required super.targetDate,
  });

  @HiveField(0)
  @override
  String get id => super.id;

  @HiveField(1)
  @override
  String get name => super.name;

  @HiveField(2)
  @override
  double get targetAmount => super.targetAmount;

  @HiveField(3)
  @override
  double get currentAmount => super.currentAmount;

  @HiveField(4)
  @override
  DateTime get targetDate => super.targetDate;

  factory FinancialGoalModel.fromEntity(FinancialGoal entity) {
    return FinancialGoalModel(
      id: entity.id,
      name: entity.name,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      targetDate: entity.targetDate,
    );
  }
}
