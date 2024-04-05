import 'package:hive_flutter/hive_flutter.dart';

part 'walk_model.g.dart';

@HiveType(typeId: 2)
class Walk extends HiveObject {
  @HiveField(0)
  String id = '';

  @HiveField(1)
  late double walkTime;

  @HiveField(2)
  late double walkDistance = 0.0;

  @HiveField(3)
  late String eventId;

  @HiveField(4)
  late String petId;

  @HiveField(5)
  late DateTime dateTime;
}
