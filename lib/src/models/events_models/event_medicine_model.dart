// EventMedicineModel.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventMedicineModel {
  late String id;
  late String name;
  DateTime? addDate;
  String? note;
  String? frequency;
  String? dosage;
  String? icon;
  late String eventId;
  late String petId;
  DateTime? endDate;
  DateTime? startDate;
  bool remindersEnabled = false;
  String emoji = '';
  String scheduleDetails = '';
  String medicineType = '';
  List<TimeOfDay> times = [];

  EventMedicineModel({
    required this.id,
    required this.name,
    required this.eventId,
    required this.petId,
    this.addDate,
    this.note,
    this.frequency,
    this.dosage,
    this.icon,
    this.endDate,
    this.startDate,
    this.remindersEnabled = false,
    this.emoji = '',
    this.scheduleDetails = '',
    this.medicineType = '',
    this.times = const [],
  });

  bool get isCurrent {
    final now = DateTime.now();
    return startDate != null &&
        endDate != null &&
        now.isAfter(startDate!) &&
        now.isBefore(endDate!);
  }

  EventMedicineModel.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    name = doc.get('name') ?? '';
    eventId = doc.get('eventId') ?? '';
    petId = doc.get('petId') ?? '';
    addDate = (doc.get('addDate') as Timestamp?)?.toDate();
    note = doc.get('note') ?? '';
    frequency = doc.get('frequency') ?? '';
    dosage = doc.get('dosage') ?? '';
    icon = doc.get('icon') ?? '';
    endDate = (doc.get('endDate') as Timestamp?)?.toDate();
    startDate = (doc.get('startDate') as Timestamp?)?.toDate();
    remindersEnabled = doc.get('remindersEnabled') ?? false;
    emoji = doc.get('emoji') ?? '';
    scheduleDetails = doc.get('scheduleDetails') ?? '';
    medicineType = doc.get('medicineType') ?? '';
    times = (doc.get('times') as List<dynamic>?)
            ?.map((e) => _fromJsonTimeOfDay(e))
            .toList() ??
        [];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'eventId': eventId,
      'petId': petId,
      'addDate': addDate,
      'note': note,
      'frequency': frequency,
      'dosage': dosage,
      'icon': icon,
      'endDate': endDate,
      'startDate': startDate,
      'remindersEnabled': remindersEnabled,
      'emoji': emoji,
      'scheduleDetails': scheduleDetails,
      'medicineType': medicineType,
      'times': times.map((time) => _toJsonTimeOfDay(time)).toList(),
    };
  }

  // Helper to convert TimeOfDay to JSON format
  Map<String, int> _toJsonTimeOfDay(TimeOfDay time) {
    return {'hour': time.hour, 'minute': time.minute};
  }

  // Helper to convert JSON format to TimeOfDay
  TimeOfDay _fromJsonTimeOfDay(Map<String, dynamic> json) {
    return TimeOfDay(hour: json['hour'] as int, minute: json['minute'] as int);
  }
}
