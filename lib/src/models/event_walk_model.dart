import 'package:cloud_firestore/cloud_firestore.dart';

class EventWalkModel {
  String id = '';
  late double walkTime;
  late double steps = 0.0;
  late String eventId;
  late String petId;
  late DateTime dateTime;

  EventWalkModel(
      {required this.id,
      required this.walkTime,
      required this.eventId,
      required this.petId,
      required this.steps,
      required this.dateTime});

  EventWalkModel.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    walkTime = doc.get('walkTime');
    steps = doc.get('steps') ?? 0.0;
    eventId = doc.get('eventId') ?? '';
    petId = doc.get('petId') ?? '';
    dateTime = (doc.get('dateTime') as Timestamp?)?.toDate() ?? DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'walkTime': walkTime,
      'steps': steps,
      'eventId': eventId,
      'petId': petId,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }
}
