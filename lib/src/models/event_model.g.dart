// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 1;

  @override
  Event read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Event(
      title: fields[1] as String,
      date: fields[2] as DateTime,
      description: fields[3] as String,
      id: fields[0] as String,
      durationTime: fields[4] as int,
      value: fields[5] as double,
      userId: fields[6] as String,
      petId: fields[7] as String,
      weightId: fields[8] as String,
      temperatureId: fields[9] as String,
      walkId: fields[10] as String,
      waterId: fields[11] as String,
      noteId: fields[12] as String,
      pillId: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.durationTime)
      ..writeByte(5)
      ..write(obj.value)
      ..writeByte(6)
      ..write(obj.userId)
      ..writeByte(7)
      ..write(obj.petId)
      ..writeByte(8)
      ..write(obj.weightId)
      ..writeByte(9)
      ..write(obj.temperatureId)
      ..writeByte(10)
      ..write(obj.walkId)
      ..writeByte(11)
      ..write(obj.waterId)
      ..writeByte(12)
      ..write(obj.noteId)
      ..writeByte(13)
      ..write(obj.pillId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
