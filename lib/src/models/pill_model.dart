import 'package:hive_flutter/hive_flutter.dart';
part 'pill_model.g.dart';

@HiveType(typeId: 3)
class Pill extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  DateTime? addDate;

  @HiveField(3)
  String? note;

  @HiveField(4)
  String? frequency;

  @HiveField(5)
  List<String>? times;

  @HiveField(6)
  String? dosage;

  @HiveField(7)
  String? icon;

  @HiveField(8)
  int? color;

  @HiveField(9)
  late String eventId;

  @HiveField(10)
  late String petId;

  @HiveField(11)
  DateTime? endDate;

  @HiveField(12)
  DateTime? startDate;

  @HiveField(13)
  String? timesPerDay;

  @HiveField(14)
  bool remindersEnabled = false;

  @HiveField(15)
  String emoji = '';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'name': name,
      'expirationDate': addDate?.toIso8601String(),
      'note': note,
      'frequency': frequency,
      'times': times,
      'dosage': dosage,
      'icon': icon,
      'color': color,
      'eventId': eventId,
      'petId': petId,
    };
  }
}
