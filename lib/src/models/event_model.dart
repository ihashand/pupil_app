import 'package:hive_flutter/hive_flutter.dart';

part 'event_model.g.dart';

@HiveType(typeId: 1)
class Event extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String description;

  @HiveField(4)
  int durationTime;

  @HiveField(5)
  double weight;

  Event(
      {required this.title,
      required this.date,
      this.description = '',
      required this.id,
      r,
      this.durationTime = 0,
      this.weight = 0});
}
