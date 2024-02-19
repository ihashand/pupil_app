import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/pet_walk_model.dart';
import 'package:pet_diary/src/models/pill_model.dart';
import 'package:pet_diary/src/models/temperature_model.dart';
import 'package:pet_diary/src/models/weight_model.dart';

part 'pet_model.g.dart';

@HiveType(typeId: 0)
class Pet extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String image;

  @HiveField(3)
  late String age;

  @HiveField(4)
  late String gender;

  @HiveField(5)
  late String color;

  @HiveField(6)
  late List<Weight> weights;

  @HiveField(7)
  late List<Temperature> temperatures;

  @HiveField(8)
  late List<Pill> pills;

  @HiveField(9)
  late List<PetWalk> walks;

  @HiveField(10)
  late List<Event> events;

  @HiveField(11)
  late String userId;

  Pet({
    required this.id,
    required this.name,
    required this.image,
    required this.age,
    required this.gender,
    required this.color,
    required this.weights,
    required this.temperatures,
    required this.pills,
    required this.walks,
    required this.events,
    required this.userId,
  });
}
