// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetAdapter extends TypeAdapter<Pet> {
  @override
  final int typeId = 0;

  @override
  Pet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pet(
      id: fields[0] as String,
      name: fields[1] as String,
      avatarImage: fields[2] as String,
      age: fields[3] as String,
      gender: fields[4] as String,
      userId: fields[5] as String,
      breed: fields[6] as String,
      dateTime: fields[7] as DateTime,
      backgroundImage: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Pet obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.avatarImage)
      ..writeByte(3)
      ..write(obj.age)
      ..writeByte(4)
      ..write(obj.gender)
      ..writeByte(5)
      ..write(obj.userId)
      ..writeByte(6)
      ..write(obj.breed)
      ..writeByte(7)
      ..write(obj.dateTime)
      ..writeByte(8)
      ..write(obj.backgroundImage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
