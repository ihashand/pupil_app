import 'package:hive_flutter/hive_flutter.dart';
part 'pill_model.g.dart';

@HiveType(typeId: 3)
class Pill extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late DateTime date;
}
