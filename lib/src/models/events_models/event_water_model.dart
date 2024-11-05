import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventWaterModel {
  String id;
  String eventId;
  String petId;
  String userId; // Dodano pole userId
  double? water;
  String? waterLevel;
  DateTime dateTime;
  String? name;
  TimeOfDay? time;

  EventWaterModel({
    required this.id,
    required this.eventId,
    required this.petId,
    required this.userId,
    this.water,
    this.waterLevel,
    required this.dateTime,
    this.name,
    this.time,
  });

  EventWaterModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        eventId = doc.get('eventId') ?? '',
        petId = doc.get('petId') ?? '',
        userId = doc.get('userId') ?? '',
        water = doc.get('water'),
        waterLevel = doc.get('waterLevel'),
        dateTime =
            (doc.get('dateTime') as Timestamp?)?.toDate() ?? DateTime.now(),
        name = doc.get('name'),
        time = (doc.get('time') != null)
            ? TimeOfDay(
                hour: (doc.get('time')['hour'] as int?) ?? 0,
                minute: (doc.get('time')['minute'] as int?) ?? 0,
              )
            : null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'petId': petId,
      'userId': userId,
      'water': water,
      'waterLevel': waterLevel,
      'dateTime': Timestamp.fromDate(dateTime),
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
