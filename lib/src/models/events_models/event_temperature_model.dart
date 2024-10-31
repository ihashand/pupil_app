import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventTemperatureModel {
  late String id;
  late double temperature;
  late String eventId;
  late String petId;
  late String userId;
  late DateTime dateTime;
  late TimeOfDay time;

  EventTemperatureModel({
    required this.id,
    required this.temperature,
    required this.eventId,
    required this.petId,
    required this.userId,
    required this.dateTime,
    required this.time,
  });

  EventTemperatureModel.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    temperature = doc.get('temperature');
    eventId = doc.get('eventId') ?? '';
    petId = doc.get('petId') ?? '';
    userId = doc.get('userId') ?? '';
    dateTime = (doc.get('dateTime') as Timestamp?)?.toDate() ?? DateTime.now();
    final timeData = (doc.get('time') as Map?) ?? {'hour': 0, 'minute': 0};
    time =
        TimeOfDay(hour: timeData['hour'] ?? 0, minute: timeData['minute'] ?? 0);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'temperature': temperature,
      'eventId': eventId,
      'petId': petId,
      'userId': userId,
      'dateTime': Timestamp.fromDate(dateTime),
      'time': {'hour': time.hour, 'minute': time.minute},
    };
  }
}
