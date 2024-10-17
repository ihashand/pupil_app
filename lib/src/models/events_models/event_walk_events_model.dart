import 'package:cloud_firestore/cloud_firestore.dart';

class EventWalkEventsModel {
  String id;
  String eventId;
  String petId;
  String eventType;
  DateTime eventTime;
  String description;

  EventWalkEventsModel({
    required this.id,
    required this.eventId,
    required this.petId,
    required this.eventType,
    required this.eventTime,
    required this.description,
  });

  EventWalkEventsModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        eventId = doc.get('eventId'),
        petId = doc.get('petId'),
        eventType = doc.get('eventType'),
        eventTime = (doc.get('eventTime') as Timestamp).toDate(),
        description = doc.get('description');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'petId': petId,
      'eventType': eventType,
      'eventTime': Timestamp.fromDate(eventTime),
      'description': description,
    };
  }
}
