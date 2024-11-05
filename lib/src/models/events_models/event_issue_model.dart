import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventIssueModel {
  String id;
  String eventId;
  String petId;
  String userId;
  String emoji;
  String description;
  DateTime dateTime;
  TimeOfDay? time;

  EventIssueModel({
    required this.id,
    required this.eventId,
    required this.petId,
    required this.userId,
    required this.emoji,
    required this.description,
    required this.dateTime,
    this.time,
  });

  EventIssueModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        eventId = doc.get('eventId'),
        petId = doc.get('petId'),
        userId = doc.get('userId'),
        emoji = doc.get('emoji'),
        description = doc.get('description'),
        dateTime = (doc.get('dateTime') as Timestamp).toDate(),
        time =
            (doc.data() as Map<String, dynamic>?)?.containsKey('time') == true
                ? TimeOfDay(
                    hour: (doc.get('time')['hour'] as int),
                    minute: (doc.get('time')['minute'] as int),
                  )
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
      if (time != null) 'time': {'hour': time!.hour, 'minute': time!.minute},
    };
  }
}
