import 'package:cloud_firestore/cloud_firestore.dart';

class EventMoodModel {
  String id;
  String eventId;
  String petId;
  String emoji;
  String description;
  DateTime dateTime;
  int moodRating;

  EventMoodModel({
    required this.id,
    required this.eventId,
    required this.petId,
    required this.emoji,
    required this.description,
    required this.dateTime,
    required this.moodRating,
  });

  EventMoodModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        eventId = doc.get('eventId'),
        petId = doc.get('petId'),
        emoji = doc.get('emoji'),
        description = doc.get('description'),
        dateTime = (doc.get('dateTime') as Timestamp).toDate(),
        moodRating = doc.get('moodRating');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'petId': petId,
      'emoji': emoji,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'moodRating': moodRating,
    };
  }

  static int determineMoodRating(String emoji) {
    switch (emoji) {
      case '😄':
        return 10; // Cudowne
      case '😃':
        return 9; // Bardzo dobre
      case '😊':
        return 8; // Dobre
      case '😐':
        return 5; // Neutralne
      case '😴':
        return 4; // Tired
      case '😢':
        return 2; // Sad
      case '😠':
        return 3; // Angry
      case '😡':
        return 2; // Furious
      case '😭':
        return 1; // Crying
      case '😞':
        return 3; // Disappointed
      default:
        return 5; // Domyślna ocena
    }
  }
}
