// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'walk_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalkAdapter extends TypeAdapter<Walk> {
  @override
  final int typeId = 2;

  @override
  Walk read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Walk()
      ..id = fields[0] as String
      ..walkTime = fields[1] as double
      ..walkDistance = fields[2] as double
      ..eventId = fields[3] as String
      ..petId = fields[4] as String
      ..dateTime = fields[5] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Walk obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.walkTime)
      ..writeByte(2)
      ..write(obj.walkDistance)
      ..writeByte(3)
      ..write(obj.eventId)
      ..writeByte(4)
      ..write(obj.petId)
      ..writeByte(5)
      ..write(obj.dateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
