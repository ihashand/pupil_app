import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  late String id;
  late String title;
  late String eventId;
  late String petId;
  late DateTime dateTime;
  late String contentText;

  Note.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    title = doc.get('name') ?? '';
    eventId = doc.get('eventId') ?? '';
    petId = doc.get('petId') ?? '';
    dateTime = (doc.get('dateTime') as Timestamp?)?.toDate() ?? DateTime.now();
    contentText = doc.get('contentText') ?? '';
  }
  Note({
    required this.id,
    required this.title,
    required this.eventId,
    required this.petId,
    required this.dateTime,
    required this.contentText,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'eventId': eventId,
      'petId': petId,
      'dateTime': dateTime,
      'contentText': contentText,
    };
  }
}
