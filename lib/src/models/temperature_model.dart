import 'package:hive_flutter/hive_flutter.dart';
part 'temperature_model.g.dart';

@HiveType(typeId: 4)
class Temperature extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late double temperature;
}
