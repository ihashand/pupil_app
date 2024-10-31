import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventWeightModel {
  String id;
  double weight;
  String eventId;
  String petId;
  String userId;
  DateTime dateTime;
  TimeOfDay? time;

  EventWeightModel({
    required this.id,
    required this.weight,
    required this.eventId,
    required this.petId,
    required this.userId,
    required this.dateTime,
    this.time,
  });

  EventWeightModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        weight = doc.get('weight') ?? 0.0,
        eventId = doc.get('eventId') ?? '',
        petId = doc.get('petId') ?? '',
        userId = doc.get('userId') ?? '',
        dateTime = (doc.get('dateTime') as Timestamp).toDate(),
        time = (doc.data() as Map<String, dynamic>).containsKey('time')
            ? TimeOfDay.fromDateTime((doc.get('time') as Timestamp).toDate())
            : null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'eventId': eventId,
      'petId': petId,
      'userId': userId,
      'dateTime': Timestamp.fromDate(dateTime),
      if (time != null)
        'time': Timestamp.fromDate(
          DateTime(dateTime.year, dateTime.month, dateTime.day, time!.hour,
              time!.minute),
        ),
    };
  }
}
