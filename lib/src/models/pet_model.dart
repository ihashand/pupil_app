import 'package:hive_flutter/hive_flutter.dart';

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

  Pet({
    required this.id,
    required this.name,
    required this.image,
    required this.age,
  });
}
