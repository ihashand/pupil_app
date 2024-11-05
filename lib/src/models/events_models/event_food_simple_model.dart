import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventFoodSimpleModel {
  String id;
  String eventId;
  String petId;
  String userId;
  String foodType;
  double? foodAmount;
  DateTime dateTime;
  String? name;
  TimeOfDay? time;
  int? satisfactionLevel;

  EventFoodSimpleModel({
    required this.id,
    required this.eventId,
    required this.petId,
    required this.userId,
    required this.foodType,
    this.foodAmount,
    required this.dateTime,
    this.name,
    this.time,
    this.satisfactionLevel,
  });

  EventFoodSimpleModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        eventId = doc.get('eventId'),
        petId = doc.get('petId'),
        userId = doc.get('userId'),
        foodType = doc.get('foodType'),
        foodAmount = doc.get('foodAmount')?.toDouble(),
        dateTime = (doc.get('dateTime') as Timestamp).toDate(),
        name = (doc.data() as Map<String, dynamic>?)?['name'],
        time = (doc.data() as Map<String, dynamic>?)?['time'] != null
            ? TimeOfDay.fromDateTime(
                (doc.get('time') as Timestamp).toDate(),
              )
            : null,
        satisfactionLevel =
            (doc.data() as Map<String, dynamic>?)?['satisfactionLevel'];

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'petId': petId,
      'userId': userId,
      'foodType': foodType,
      'foodAmount': foodAmount,
      'dateTime': Timestamp.fromDate(dateTime),
      'name': name,
      'time': time != null
          ? Timestamp.fromDate(DateTime(dateTime.year, dateTime.month,
              dateTime.day, time!.hour, time!.minute))
          : null,
      'satisfactionLevel': satisfactionLevel,
    };
  }
}
