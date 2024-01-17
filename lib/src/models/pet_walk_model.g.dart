// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_walk_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetWalkAdapter extends TypeAdapter<PetWalk> {
  @override
  final int typeId = 2;

  @override
  PetWalk read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PetWalk()
      ..id = fields[0] as String
      ..walkTime = fields[1] as int
      ..walkDistance = fields[2] as double;
  }

  @override
  void write(BinaryWriter writer, PetWalk obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.walkTime)
      ..writeByte(2)
      ..write(obj.walkDistance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetWalkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
