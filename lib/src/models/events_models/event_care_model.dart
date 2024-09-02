import 'package:cloud_firestore/cloud_firestore.dart';

class EventCareModel {
  String id;
  String eventId;
  String petId;
  String careType;
  String emoji;
  String description;
  DateTime dateTime;

  EventCareModel({
    required this.id,
    required this.eventId,
    required this.petId,
    required this.careType,
    required this.emoji,
    required this.description,
    required this.dateTime,
  });

  EventCareModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        eventId = doc.get('eventId'),
        petId = doc.get('petId'),
        careType = doc.get('careType'),
        emoji = doc.get('emoji'),
        description = doc.get('description'),
        dateTime = (doc.get('dateTime') as Timestamp).toDate();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'petId': petId,
      'careType': careType,
      'emoji': emoji,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }
}
