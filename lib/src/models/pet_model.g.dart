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
      image: fields[2] as String,
      age: fields[3] as String,
      gender: fields[4] as String,
      color: fields[5] as String,
      weights: (fields[6] as List).cast<Weight>(),
      temperatures: (fields[7] as List).cast<Temperature>(),
      pills: (fields[8] as List).cast<Pill>(),
      walks: (fields[9] as List).cast<PetWalk>(),
      events: (fields[10] as List).cast<Event>(),
    );
  }

  @override
  void write(BinaryWriter writer, Pet obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.image)
      ..writeByte(3)
      ..write(obj.age)
      ..writeByte(4)
      ..write(obj.gender)
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.weights)
      ..writeByte(7)
      ..write(obj.temperatures)
      ..writeByte(8)
      ..write(obj.pills)
      ..writeByte(9)
      ..write(obj.walks)
      ..writeByte(10)
      ..write(obj.events);
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
