import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class TimeOfDayAdapter extends TypeAdapter<TimeOfDay> {
  @override
  final typeId = 10; // Upewnij się, że ten ID typu jest unikalny

  @override
  TimeOfDay read(BinaryReader reader) {
    final timeString = reader.readString();
    final timeParts = timeString.split(':');
    return TimeOfDay(
        hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
  }

  @override
  void write(BinaryWriter writer, TimeOfDay obj) {
    writer.writeString('${obj.hour}:${obj.minute}');
  }
}
