import 'package:hive_flutter/hive_flutter.dart';

part 'pet_model.g.dart';

@HiveType(typeId: 0)
class Pet extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String avatarImage;

  @HiveField(3)
  late String age;

  @HiveField(4)
  late String gender;

  @HiveField(5)
  late String userId;

  @HiveField(6)
  late String breed;

  @HiveField(7)
  late DateTime dateTime;

  @HiveField(8)
  late String backgroundImage;

  Pet({
    required this.id,
    required this.name,
    required this.avatarImage,
    required this.age,
    required this.gender,
    required this.userId,
    required this.breed,
    required this.dateTime,
    required this.backgroundImage,
  });
}
