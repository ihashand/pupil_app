import 'package:hive_flutter/hive_flutter.dart';
part 'weight_model.g.dart';

@HiveType(typeId: 5)
class Weight extends HiveObject {
  @HiveField(0)
  String id = '';

  @HiveField(1)
  late double weight = 0.0;

  @HiveField(2)
  late String eventId;

  @HiveField(3)
  late String petId;

  @HiveField(4)
  late DateTime dateTime;
}
