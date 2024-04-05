// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeightAdapter extends TypeAdapter<Weight> {
  @override
  final int typeId = 5;

  @override
  Weight read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Weight()
      ..id = fields[0] as String
      ..weight = fields[1] as double
      ..eventId = fields[2] as String
      ..petId = fields[3] as String
      ..dateTime = fields[4] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Weight obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.weight)
      ..writeByte(2)
      ..write(obj.eventId)
      ..writeByte(3)
      ..write(obj.petId)
      ..writeByte(4)
      ..write(obj.dateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
