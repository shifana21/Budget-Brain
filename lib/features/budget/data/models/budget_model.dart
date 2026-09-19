import 'package:hive/hive.dart';
import '../../domain/entities/budget.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 2)
class BudgetModel extends Budget {
  const BudgetModel({
    required super.category,
    required super.monthlyLimit,
    required super.spentAmount,
  });

  @HiveField(0)
  @override
  String get category => super.category;

  @HiveField(1)
  @override
  double get monthlyLimit => super.monthlyLimit;

  @HiveField(2)
  @override
  double get spentAmount => super.spentAmount;

  factory BudgetModel.fromEntity(Budget entity) {
    return BudgetModel(
      category: entity.category,
      monthlyLimit: entity.monthlyLimit,
      spentAmount: entity.spentAmount,
    );
  }
}
