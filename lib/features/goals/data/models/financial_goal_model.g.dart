// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_goal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FinancialGoalModelAdapter extends TypeAdapter<FinancialGoalModel> {
  @override
  final int typeId = 3;

  @override
  FinancialGoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FinancialGoalModel(
      id: fields[0] as String,
      name: fields[1] as String,
      targetAmount: fields[2] as double,
      currentAmount: fields[3] as double,
      targetDate: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FinancialGoalModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.targetAmount)
      ..writeByte(3)
      ..write(obj.currentAmount)
      ..writeByte(4)
      ..write(obj.targetDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinancialGoalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
