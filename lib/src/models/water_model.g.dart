// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WaterAdapter extends TypeAdapter<Water> {
  @override
  final int typeId = 7;

  @override
  Water read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Water()
      ..id = fields[0] as String
      ..eventId = fields[1] as String
      ..petId = fields[2] as String
      ..water = fields[3] as double;
  }

  @override
  void write(BinaryWriter writer, Water obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.eventId)
      ..writeByte(2)
      ..write(obj.petId)
      ..writeByte(3)
      ..write(obj.water);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WaterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
