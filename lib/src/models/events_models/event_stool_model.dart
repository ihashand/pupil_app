import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventStoolModel {
  String id;
  String eventId;
  String petId;
  String userId;
  String emoji;
  String description;
  DateTime dateTime;
  TimeOfDay? time;

  EventStoolModel({
    required this.id,
    required this.eventId,
    required this.petId,
    required this.userId,
    required this.emoji,
    required this.description,
    required this.dateTime,
    this.time,
  });

  EventStoolModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        eventId = doc.get('eventId'),
        petId = doc.get('petId'),
        userId = doc.get('userId'),
        emoji = doc.get('emoji'),
        description = doc.get('description'),
        dateTime = (doc.get('dateTime') as Timestamp).toDate(),
        time = doc.get('time') != null
            ? TimeOfDay.fromDateTime((doc.get('time') as Timestamp).toDate())
            : null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'petId': petId,
      'userId': userId,
      'emoji': emoji,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      if (time != null)
        'time': Timestamp.fromDate(DateTime(
          dateTime.year,
          dateTime.month,
          dateTime.day,
          time!.hour,
          time!.minute,
        )),
    };
  }
}
