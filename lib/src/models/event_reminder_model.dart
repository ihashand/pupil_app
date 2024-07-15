import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventReminderModel {
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
  late DateTime endDate;
  late List<String> selectedPets; // Nowe pole

  EventReminderModel({
    required this.id,
    required this.time,
    required this.userId,
    required this.objectId,
    this.title = '',
    this.description = '',
    required this.selectedDays,
    this.repeatOption = 'Once',
    this.repeatInterval,
    required this.dateTime,
    required this.endDate,
    required this.selectedPets, // Nowe pole
  });

  EventReminderModel.fromDocument(DocumentSnapshot doc) {
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
    repeatOption = doc.get('repeatOption') ?? 'Once';
    repeatInterval = doc.get('repeatInterval');
    dateTime = (doc.get('dateTime') as Timestamp?)?.toDate() ?? DateTime.now();
    endDate = (doc.get('endDate') as Timestamp?)?.toDate() ??
        DateTime.now(); // nowe pole
    var selectedPetsData = doc.get('selectedPets');
    selectedPets = selectedPetsData != null && selectedPetsData is List
        ? List<String>.from(selectedPetsData)
        : [];
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
      'endDate': Timestamp.fromDate(endDate), // nowe pole
      'selectedPets': selectedPets,
    };
  }
}
