import 'package:hive/hive.dart';

part 'pet_model.g.dart'; // Generated file

@HiveType(typeId: 0)
class Pet extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  Pet({required this.id, required this.name});
}
