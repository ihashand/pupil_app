import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventVaccineModel {
  String id;
  String eventId;
  String petId;
  String emoticon;
  String description;
  DateTime dateTime;
  String? dose;
  String userId;
  String? name;
  TimeOfDay? time;

  EventVaccineModel({
    required this.id,
    required this.eventId,
    required this.petId,
    required this.emoticon,
    required this.description,
    required this.dateTime,
    required this.userId,
    this.dose,
    this.name,
    this.time,
  });

  EventVaccineModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        eventId = doc.get('eventId'),
        petId = doc.get('petId'),
        emoticon = doc.get('emoticon'),
        description = doc.get('description'),
        dateTime = (doc.get('dateTime') as Timestamp).toDate(),
        dose = doc.get('dose'),
        userId = doc.get('userId'),
        name = doc.get('name'),
        time = doc.get('time') != null
            ? TimeOfDay(
                hour: (doc.get('time') as Map)['hour'],
                minute: (doc.get('time') as Map)['minute'],
              )
            : null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'petId': petId,
      'emoticon': emoticon,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'dose': dose,
      'userId': userId,
      'name': name,
      'time': time != null
          ? {
              'hour': time!.hour,
              'minute': time!.minute,
            }
          : null,
    };
  }
}
