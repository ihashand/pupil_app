import 'package:hive_flutter/hive_flutter.dart';
part 'note_model.g.dart';

@HiveType(typeId: 8)
class Note extends HiveObject {
  @HiveField(0)
  String id = '';

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String eventId;

  @HiveField(3)
  late String petId;

  @HiveField(4)
  late DateTime dateTime;

  @HiveField(5)
  late String contentText;
}
