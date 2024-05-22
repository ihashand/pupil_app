import 'package:cloud_firestore/cloud_firestore.dart';

class EventStoolModel {
  String id;
  String eventId;
  String petId;
  String emoji;
  String description;
  DateTime dateTime;

  EventStoolModel({
    required this.id,
    required this.eventId,
    required this.petId,
    required this.emoji,
    required this.description,
    required this.dateTime,
  });

  EventStoolModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        eventId = doc.get('eventId'),
        petId = doc.get('petId'),
        emoji = doc.get('emoji'),
        description = doc.get('description'),
        dateTime = (doc.get('dateTime') as Timestamp).toDate();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'petId': petId,
      'emoji': emoji,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }
}
