// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 9;

  @override
  Reminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reminder(
      time: fields[1] as TimeOfDay,
      id: fields[0] as String,
      userId: fields[4] as String,
      objectId: fields[5] as String,
      title: fields[2] as String,
      description: fields[3] as String,
      repeatType: fields[6] as String,
    )..dateTime = fields[7] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.userId)
      ..writeByte(5)
      ..write(obj.objectId)
      ..writeByte(6)
      ..write(obj.repeatType)
      ..writeByte(7)
      ..write(obj.dateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
