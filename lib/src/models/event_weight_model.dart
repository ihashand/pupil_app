import 'package:cloud_firestore/cloud_firestore.dart';

class EventWeightModel {
  String id = '';
  late double weight = 0.0;
  late String eventId;
  late String petId;
  late DateTime dateTime;

  EventWeightModel({
    required this.id,
    required this.weight,
    required this.eventId,
    required this.petId,
    required this.dateTime,
  });

  EventWeightModel.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    weight = doc.get('weight') ?? 0.0;
    eventId = doc.get('eventId') ?? '';
    petId = doc.get('petId') ?? '';
    dateTime = (doc.get('dateTime') as Timestamp?)?.toDate() ?? DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'eventId': eventId,
      'petId': petId,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }
}
