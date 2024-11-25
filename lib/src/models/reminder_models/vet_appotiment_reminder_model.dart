import 'package:flutter/material.dart';

/// Model representing a vet appointment.
class VetAppointmentModel {
  final String id;
  final String userId;
  final DateTime date;
  final TimeOfDay time;
  final List<String> assignedPetIds;
  final String reason;

  VetAppointmentModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.time,
    required this.assignedPetIds,
    required this.reason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'assignedPetIds': assignedPetIds,
      'reason': reason,
    };
  }

  factory VetAppointmentModel.fromMap(Map<String, dynamic> map) {
    final timeParts = map['time'].split(':');
    return VetAppointmentModel(
      id: map['id'],
      userId: map['userId'],
      date: DateTime.parse(map['date']),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      assignedPetIds: List<String>.from(map['assignedPetIds']),
      reason: map['reason'],
    );
  }
}
