import 'package:hive_flutter/hive_flutter.dart';

part 'pet_walk_model.g.dart';

@HiveType(typeId: 2)
class PetWalk extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late int walkTime;

  @HiveField(2)
  late double walkDistance;

  @HiveField(3)
  late String eventId;

  @HiveField(4)
  late String petId;
}
