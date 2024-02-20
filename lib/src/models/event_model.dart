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

  @HiveField(6)
  String userId;

  @HiveField(7)
  String petId;

  Event(
      {required this.title,
      required this.date,
      required this.description,
      required this.id,
      required this.durationTime,
      required this.weight,
      required this.userId,
      required this.petId});
}
