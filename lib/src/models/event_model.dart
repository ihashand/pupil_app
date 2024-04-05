import 'package:hive_flutter/hive_flutter.dart';

part 'event_model.g.dart';

@HiveType(typeId: 1)
class Event extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime eventDate;

  @HiveField(3)
  DateTime dateWhenEventAdded;

  @HiveField(4)
  String userId;

  @HiveField(5)
  String petId;

  @HiveField(6)
  String weightId;

  @HiveField(7)
  String temperatureId;

  @HiveField(8)
  String walkId;

  @HiveField(9)
  String waterId;

  @HiveField(10)
  String noteId;

  @HiveField(11)
  String pillId;

  Event(
      {required this.id,
      required this.title,
      required this.eventDate,
      required this.dateWhenEventAdded,
      required this.userId,
      required this.petId,
      required this.weightId,
      required this.temperatureId,
      required this.walkId,
      required this.waterId,
      required this.noteId,
      required this.pillId});
}
