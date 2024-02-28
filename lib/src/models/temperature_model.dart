import 'package:hive_flutter/hive_flutter.dart';
part 'temperature_model.g.dart';

@HiveType(typeId: 4)
class Temperature extends HiveObject {
  @HiveField(0)
  String id = '';

  @HiveField(1)
  late double temperature;

  @HiveField(2)
  late String eventId;

  @HiveField(3)
  late String petId;
}
