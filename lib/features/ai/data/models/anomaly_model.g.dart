// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anomaly_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnomalyModelAdapter extends TypeAdapter<AnomalyModel> {
  @override
  final int typeId = 4;

  @override
  AnomalyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnomalyModel(
      transactionId: fields[0] as String,
      riskLevel: fields[1] as String,
      message: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AnomalyModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.transactionId)
      ..writeByte(1)
      ..write(obj.riskLevel)
      ..writeByte(2)
      ..write(obj.message);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnomalyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
