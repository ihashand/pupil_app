import 'package:cloud_firestore/cloud_firestore.dart';

class EventServiceModel {
  String id;
  String eventId;
  String petId;
  String serviceType;
  String emoji;
  String description;
  DateTime dateTime;

  EventServiceModel({
    required this.id,
    required this.eventId,
    required this.petId,
    required this.serviceType,
    required this.emoji,
    required this.description,
    required this.dateTime,
  });

  EventServiceModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        eventId = doc.get('eventId'),
        petId = doc.get('petId'),
        serviceType = doc.get('serviceType'),
        emoji = doc.get('emoji'),
        description = doc.get('description'),
        dateTime = (doc.get('dateTime') as Timestamp).toDate();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'petId': petId,
      'serviceType': serviceType,
      'emoji': emoji,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }
}
