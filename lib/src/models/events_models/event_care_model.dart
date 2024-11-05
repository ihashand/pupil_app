import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventCareModel {
  String id;
  String eventId;
  String petId;
  String careType;
  String emoji;
  String description;
  DateTime dateTime;
  TimeOfDay? time; // Dodane pole dla czasu

  EventCareModel({
    required this.id,
    required this.eventId,
    required this.petId,
    required this.careType,
    required this.emoji,
    required this.description,
    required this.dateTime,
    this.time, // Konstruktor z opcjonalnym polem czasu
  });

  EventCareModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        eventId = doc.get('eventId'),
        petId = doc.get('petId'),
        careType = doc.get('careType'),
        emoji = doc.get('emoji'),
        description = doc.get('description'),
        dateTime = (doc.get('dateTime') as Timestamp).toDate(),
        time = doc.get('time') != null
            ? TimeOfDay.fromDateTime((doc.get('time') as Timestamp).toDate())
            : null; // Pobieranie czasu

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'petId': petId,
      'careType': careType,
      'emoji': emoji,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'time': time != null
          ? Timestamp.fromDate(DateTime(2000, 1, 1, time!.hour, time!.minute))
          : null, // Zapis czasu
    };
  }
}
