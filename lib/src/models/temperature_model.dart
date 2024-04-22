import 'package:cloud_firestore/cloud_firestore.dart';

class Temperature {
  late String id;
  late double temperature;
  late String eventId;
  late String petId;
  late DateTime dateTime;

  Temperature({
    required this.id,
    required this.temperature,
    required this.eventId,
    required this.petId,
  }) : dateTime = DateTime.now();

  Temperature.fromDocument(DocumentSnapshot doc) {
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
