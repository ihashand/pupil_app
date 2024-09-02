import 'package:cloud_firestore/cloud_firestore.dart';

class EventVaccineModel {
  String id;
  String eventId;
  String petId;
  String emoticon;
  String description;
  DateTime dateTime;
  String? dose;

  EventVaccineModel({
    required this.id,
    required this.eventId,
    required this.petId,
    required this.emoticon,
    required this.description,
    required this.dateTime,
    this.dose,
  });

  EventVaccineModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        eventId = doc.get('eventId'),
        petId = doc.get('petId'),
        emoticon = doc.get('emoticon'),
        description = doc.get('description'),
        dateTime = (doc.get('dateTime') as Timestamp).toDate(),
        dose = doc.get('dose');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'petId': petId,
      'emoticon': emoticon,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'dose': dose,
    };
  }
}
