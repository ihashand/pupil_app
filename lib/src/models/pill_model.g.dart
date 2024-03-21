// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pill_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PillAdapter extends TypeAdapter<Pill> {
  @override
  final int typeId = 3;

  @override
  Pill read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pill()
      ..id = fields[0] as String
      ..name = fields[1] as String
      ..addDate = fields[2] as DateTime?
      ..note = fields[3] as String?
      ..frequency = fields[4] as String?
      ..times = (fields[5] as List?)?.cast<String>()
      ..dosage = fields[6] as String?
      ..icon = fields[7] as String?
      ..color = fields[8] as int?
      ..eventId = fields[9] as String
      ..petId = fields[10] as String
      ..endDate = fields[11] as DateTime?
      ..startDate = fields[12] as DateTime?
      ..timesPerDay = fields[13] as String?
      ..remindersEnabled = fields[14] as bool
      ..emoji = fields[15] as String;
  }

  @override
  void write(BinaryWriter writer, Pill obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.addDate)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.frequency)
      ..writeByte(5)
      ..write(obj.times)
      ..writeByte(6)
      ..write(obj.dosage)
      ..writeByte(7)
      ..write(obj.icon)
      ..writeByte(8)
      ..write(obj.color)
      ..writeByte(9)
      ..write(obj.eventId)
      ..writeByte(10)
      ..write(obj.petId)
      ..writeByte(11)
      ..write(obj.endDate)
      ..writeByte(12)
      ..write(obj.startDate)
      ..writeByte(13)
      ..write(obj.timesPerDay)
      ..writeByte(14)
      ..write(obj.remindersEnabled)
      ..writeByte(15)
      ..write(obj.emoji);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PillAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
