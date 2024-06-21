import 'package:cloud_firestore/cloud_firestore.dart';

class EventUrineModel {
  String id;
  String eventId;
  String petId;
  String color;
  String description;
  DateTime dateTime;

  EventUrineModel({
    required this.id,
    required this.eventId,
    required this.petId,
    required this.color,
    required this.description,
    required this.dateTime,
  });

  EventUrineModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        eventId = doc.get('eventId'),
        petId = doc.get('petId'),
        color = doc.get('color'),
        description = doc.get('description'),
        dateTime = (doc.get('dateTime') as Timestamp).toDate();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'petId': petId,
      'color': color,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }
}
