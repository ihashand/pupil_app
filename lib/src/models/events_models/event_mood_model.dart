import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventMoodModel {
  String id;
  String eventId;
  String petId;
  String userId;
  String emoji;
  String description;
  DateTime dateTime;
  TimeOfDay? time;
  int moodRating;

  EventMoodModel({
    required this.id,
    required this.eventId,
    required this.petId,
    required this.userId,
    required this.emoji,
    required this.description,
    required this.dateTime,
    this.time,
    required this.moodRating,
  });

  EventMoodModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        eventId = doc.get('eventId'),
        petId = doc.get('petId'),
        userId = doc.get('userId'),
        emoji = doc.get('emoji'),
        description = doc.get('description'),
        dateTime = (doc.get('dateTime') as Timestamp).toDate(),
        time = doc.get('time') != null
            ? TimeOfDay(
                hour: doc.get('time')['hour'],
                minute: doc.get('time')['minute'],
              )
            : null,
        moodRating = doc.get('moodRating');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'petId': petId,
      'userId': userId,
      'emoji': emoji,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'time':
          time != null ? {'hour': time!.hour, 'minute': time!.minute} : null,
      'moodRating': moodRating,
    };
  }

  static int determineMoodRating(String emoji) {
    switch (emoji) {
      case '😄':
        return 10;
      case '😃':
        return 9;
      case '😊':
        return 8;
      case '😐':
        return 5;
      case '😴':
        return 4;
      case '😢':
        return 2;
      case '😠':
        return 3;
      case '😡':
        return 2;
      case '😭':
        return 1;
      case '😞':
        return 3;
      default:
        return 5;
    }
  }
}
