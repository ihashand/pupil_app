import 'package:cloud_firestore/cloud_firestore.dart';

class EventTemperatureModel {
  late String id;
  late double temperature;
  late String eventId;
  late String petId;
  late DateTime dateTime;

  EventTemperatureModel({
    required this.id,
    required this.temperature,
    required this.eventId,
    required this.petId,
  }) : dateTime = DateTime.now();

  EventTemperatureModel.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    temperature = doc.get('temperature');
    eventId = doc.get('eventId') ?? '';
    petId = doc.get('petId') ?? '';
    dateTime = (doc.get('dateTime') as Timestamp?)?.toDate() ?? DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'temperature': temperature,
      'eventId': eventId,
      'petId': petId,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }
}
