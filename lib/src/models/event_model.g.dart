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
      id: fields[0] as String,
      title: fields[1] as String,
      eventDate: fields[2] as DateTime,
      dateWhenEventAdded: fields[3] as DateTime,
      userId: fields[4] as String,
      petId: fields[5] as String,
      weightId: fields[6] as String,
      temperatureId: fields[7] as String,
      walkId: fields[8] as String,
      waterId: fields[9] as String,
      noteId: fields[10] as String,
      pillId: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.eventDate)
      ..writeByte(3)
      ..write(obj.dateWhenEventAdded)
      ..writeByte(4)
      ..write(obj.userId)
      ..writeByte(5)
      ..write(obj.petId)
      ..writeByte(6)
      ..write(obj.weightId)
      ..writeByte(7)
      ..write(obj.temperatureId)
      ..writeByte(8)
      ..write(obj.walkId)
      ..writeByte(9)
      ..write(obj.waterId)
      ..writeByte(10)
      ..write(obj.noteId)
      ..writeByte(11)
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
