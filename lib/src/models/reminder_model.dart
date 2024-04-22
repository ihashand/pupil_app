import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Reminder {
  late String id;
  late TimeOfDay time;
  late String title;
  late String objectId;
  late String userId;
  late String description;
  late List<int> selectedDays;
  late String repeatOption;
  late int? repeatInterval;
  late DateTime dateTime;

  Reminder({
    required this.id,
    required this.time,
    required this.userId,
    required this.objectId,
    this.title = '',
    this.description = '',
    required this.selectedDays,
    this.repeatOption = 'Daily',
    this.repeatInterval,
  }) : dateTime = DateTime.now();

  Reminder.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    int minutesSinceMidnight = doc.get('time');
    time = TimeOfDay(
        hour: minutesSinceMidnight ~/ 60, minute: minutesSinceMidnight % 60);
    title = doc.get('title') ?? '';
    objectId = doc.get('objectId') ?? '';
    userId = doc.get('userId') ?? '';
    description = doc.get('description') ?? '';
    var selectedDaysData = doc.get('selectedDays');
    selectedDays = selectedDaysData != null && selectedDaysData is List
        ? List<int>.from(selectedDaysData)
        : [];
    repeatOption = doc.get('repeatOption') ?? 'Daily';
    repeatInterval = doc.get('repeatInterval');
    dateTime = (doc.get('dateTime') as Timestamp?)?.toDate() ?? DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time.hour * 60 + time.minute,
      'title': title,
      'objectId': objectId,
      'userId': userId,
      'description': description,
      'selectedDays': selectedDays,
      'repeatOption': repeatOption,
      'repeatInterval': repeatInterval,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }
}
