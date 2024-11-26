import 'package:flutter/material.dart';

/// Model representing a vet appointment.
class VetAppointmentModel {
  final String id;
  final String userId;
  final DateTime date;
  final TimeOfDay time;
  final List<String> assignedPetIds;
  final String reason;
  final List<int> earlyNotificationIds; // IDs of early notifications

  VetAppointmentModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.time,
    required this.assignedPetIds,
    required this.reason,
    this.earlyNotificationIds = const [], // Default empty list
  });

  /// Create a modified copy of the current instance.
  VetAppointmentModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    TimeOfDay? time,
    List<String>? assignedPetIds,
    String? reason,
    List<int>? earlyNotificationIds,
  }) {
    return VetAppointmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      time: time ?? this.time,
      assignedPetIds: assignedPetIds ?? this.assignedPetIds,
      reason: reason ?? this.reason,
      earlyNotificationIds: earlyNotificationIds ?? this.earlyNotificationIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'assignedPetIds': assignedPetIds,
      'reason': reason,
      'earlyNotificationIds': earlyNotificationIds,
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
      earlyNotificationIds: List<int>.from(map['earlyNotificationIds'] ?? []),
    );
  }
}
