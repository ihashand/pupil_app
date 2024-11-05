import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventUrineModel {
  String id;
  String eventId;
  String petId;
  String color;
  String description;
  DateTime dateTime;
  TimeOfDay? time;
  String userId;

  EventUrineModel({
    required this.id,
    required this.eventId,
    required this.petId,
    required this.color,
    required this.description,
    required this.dateTime,
    this.time,
    required this.userId,
  });

  EventUrineModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        eventId = doc.get('eventId'),
        petId = doc.get('petId'),
        color = doc.get('color'),
        description = doc.get('description'),
        dateTime = (doc.get('dateTime') as Timestamp).toDate(),
        time = doc.data().toString().contains('time')
            ? TimeOfDay(
                hour: (doc.get('time')['hour'] as int),
                minute: (doc.get('time')['minute'] as int),
              )
            : null,
        userId = doc.get('userId');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'petId': petId,
      'color': color,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'time': time != null
          ? {
              'hour': time!.hour,
              'minute': time!.minute,
            }
          : null,
      'userId': userId,
    };
  }
}
