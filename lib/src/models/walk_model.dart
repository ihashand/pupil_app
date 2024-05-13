import 'package:cloud_firestore/cloud_firestore.dart';

class Walk {
  String id = '';
  late double walkTime;
  late double distance = 0.0;
  late String eventId;
  late String petId;
  late DateTime dateTime;

  Walk(
      {required this.id,
      required this.walkTime,
      required this.eventId,
      required this.petId,
      required this.distance,
      required this.dateTime});

  Walk.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    walkTime = doc.get('walkTime');
    distance = doc.get('walkDistance') ?? 0.0;
    eventId = doc.get('eventId') ?? '';
    petId = doc.get('petId') ?? '';
    dateTime = (doc.get('dateTime') as Timestamp?)?.toDate() ?? DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'walkTime': walkTime,
      'walkDistance': distance,
      'eventId': eventId,
      'petId': petId,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }
}
