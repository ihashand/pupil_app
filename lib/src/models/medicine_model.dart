import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'medicine_model.g.dart';

@HiveType(typeId: 0)
class Medicine {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  DateTime addDate;
  @HiveField(3)
  DateTime startDate;
  @HiveField(4)
  DateTime endDate;
  @HiveField(5)
  String dosage;
  @HiveField(6)
  String frequency;
  @HiveField(7)
  String emoji;
  @HiveField(8)
  String petId;
  @HiveField(9)
  String eventId;

  Medicine({
    required this.id,
    required this.name,
    required this.addDate,
    required this.startDate,
    required this.endDate,
    required this.dosage,
    required this.frequency,
    required this.emoji,
    required this.petId,
    required this.eventId,
  });

  // Metoda konwertująca obiekt Medicine na mapę
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'addDate': addDate.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'dosage': dosage,
      'frequency': frequency,
      'emoji': emoji,
      'petId': petId,
      'eventId': eventId
    };
  }

  // Metoda konwertująca mapę na obiekt Medicine
  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
        id: map['id'],
        name: map['name'],
        addDate: DateTime.parse(map['addDate']),
        startDate: DateTime.parse(map['startDate']),
        endDate: DateTime.parse(map['endDate']),
        dosage: map['dosage'],
        frequency: map['frequency'],
        emoji: map['emoji'],
        petId: map['petId'],
        eventId: map['eventId']);
  }

  // Metoda konwertująca dokument Firestore na obiekt Medicine
  factory Medicine.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Medicine.fromMap(data);
  }
}
