// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dog_breed_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DogBreedAdapter extends TypeAdapter<DogBreed> {
  @override
  final int typeId = 9;

  @override
  DogBreed read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DogBreed(
      name: fields[0] as String,
      group: fields[1] as String,
      section: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DogBreed obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.group)
      ..writeByte(2)
      ..write(obj.section);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DogBreedAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
