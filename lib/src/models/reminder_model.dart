import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
part 'reminder_model.g.dart';

@HiveType(typeId: 9)
class Reminder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  TimeOfDay time;

  @HiveField(2)
  String title;

  @HiveField(3)
  String description;

  @HiveField(4)
  String userId;

  @HiveField(5)
  String
      objectId; // np. moze to byc pill, zwierze, cokolwiek z czym chcemy powiazac powiadomienie NIE USUWAC --- patryk

  @HiveField(6)
  String repeatType;

  @HiveField(7)
  DateTime dateTime = DateTime.now();

  Reminder({
    required this.time,
    required this.id,
    required this.userId,
    required this.objectId,
    this.title = '',
    this.description = '',
    this.repeatType = 'daily',
  });
}
