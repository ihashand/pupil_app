import 'package:cloud_firestore/cloud_firestore.dart';

class EventWaterModel {
  String id = '';
  late String eventId;
  late String petId;
  late double water;
  late DateTime dateTime;

  EventWaterModel(
      {required this.id,
      required this.eventId,
      required this.petId,
      required this.water,
      required this.dateTime});

  EventWaterModel.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    eventId = doc.get('eventId') ?? '';
    petId = doc.get('petId') ?? '';
    water = doc.get('water') ?? 0.0;
    dateTime = (doc.get('dateTime') as Timestamp?)?.toDate() ?? DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'petId': petId,
      'water': water,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }
}
