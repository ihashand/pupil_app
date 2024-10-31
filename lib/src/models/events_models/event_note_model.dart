import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventNoteModel {
  late String id;
  late String title;
  late String eventId;
  late String petId;
  late String userId;
  late DateTime dateTime;
  late String contentText;
  late TimeOfDay time;

  EventNoteModel.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    title = doc.get('title') ?? '';
    eventId = doc.get('eventId') ?? '';
    petId = doc.get('petId') ?? '';
    userId = doc.get('userId') ?? '';
    dateTime = (doc.get('dateTime') as Timestamp?)?.toDate() ?? DateTime.now();
    contentText = doc.get('contentText') ?? '';
    final timeData = doc.get('time');
    time = timeData != null
        ? TimeOfDay(hour: timeData['hour'], minute: timeData['minute'])
        : TimeOfDay.now();
  }

  EventNoteModel({
    required this.id,
    required this.title,
    required this.eventId,
    required this.petId,
    required this.userId,
    required this.dateTime,
    required this.contentText,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'eventId': eventId,
      'petId': petId,
      'userId': userId,
      'dateTime': Timestamp.fromDate(dateTime),
      'contentText': contentText,
      'time': {'hour': time.hour, 'minute': time.minute},
    };
  }
}
