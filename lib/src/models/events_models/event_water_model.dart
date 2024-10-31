import 'package:cloud_firestore/cloud_firestore.dart';

class EventWaterModel {
  String id;
  String eventId;
  String petId;
  double? water; // null jeśli podano poziom, a nie dokładną ilość
  String? waterLevel; // mało, średnio, dużo
  DateTime dateTime;

  EventWaterModel({
    required this.id,
    required this.eventId,
    required this.petId,
    this.water,
    this.waterLevel,
    required this.dateTime,
  });

  EventWaterModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        eventId = doc.get('eventId') ?? '',
        petId = doc.get('petId') ?? '',
        water = doc.get('water'),
        waterLevel = doc.get('waterLevel'),
        dateTime =
            (doc.get('dateTime') as Timestamp?)?.toDate() ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'petId': petId,
      'water': water,
      'waterLevel': waterLevel,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }
}
