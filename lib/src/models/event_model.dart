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
  double value;

  @HiveField(6)
  String userId;

  @HiveField(7)
  String petId;

  @HiveField(8)
  String weightId;

  @HiveField(9)
  String temperatureId;

  @HiveField(10)
  String walkId;

  @HiveField(11)
  String waterId;

  @HiveField(12)
  String noteId;

  @HiveField(13)
  String pillId;

  Event(
      {required this.title,
      required this.date,
      required this.description,
      required this.id,
      required this.durationTime,
      required this.value,
      required this.userId,
      required this.petId,
      required this.weightId,
      required this.temperatureId,
      required this.walkId,
      required this.waterId,
      required this.noteId,
      required this.pillId});
}
