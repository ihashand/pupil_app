// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temperature_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TemperatureAdapter extends TypeAdapter<Temperature> {
  @override
  final int typeId = 4;

  @override
  Temperature read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Temperature()
      ..id = fields[0] as String
      ..temperature = fields[1] as double
      ..eventId = fields[2] as String
      ..petId = fields[3] as String
      ..dateTime = fields[4] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Temperature obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.temperature)
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
      other is TemperatureAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
