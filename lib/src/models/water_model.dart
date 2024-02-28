import 'package:hive_flutter/hive_flutter.dart';

part 'water_model.g.dart';

@HiveType(typeId: 7)
class Water extends HiveObject {
  @HiveField(0)
  String id = '';

  @HiveField(1)
  late String eventId;

  @HiveField(2)
  late String petId;

  @HiveField(3)
  late double water;
}
