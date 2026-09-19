import 'package:hive/hive.dart';
import '../../domain/entities/insight.dart';

part 'insight_model.g.dart';

@HiveType(typeId: 5)
class InsightModel extends Insight {
  const InsightModel({
    required super.title,
    required super.description,
    required super.impactScore,
  });

  @HiveField(0)
  @override
  String get title => super.title;

  @HiveField(1)
  @override
  String get description => super.description;

  @HiveField(2)
  @override
  double get impactScore => super.impactScore;

  factory InsightModel.fromEntity(Insight entity) {
    return InsightModel(
      title: entity.title,
      description: entity.description,
      impactScore: entity.impactScore,
    );
  }
}
