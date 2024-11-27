import 'package:flutter/material.dart';

/// Model for behaviorist reminders.
class BehavioristReminderModel {
  final String id;
  final String userId;
  final String reason;
  final List<String> assignedPetIds;
  final DateTime date;
  final TimeOfDay time;
  final List<int> earlyNotificationIds;
  final List<String> eventIds; // Store related event IDs

  BehavioristReminderModel({
    required this.id,
    required this.userId,
    required this.reason,
    required this.assignedPetIds,
    required this.date,
    required this.time,
    required this.earlyNotificationIds,
    required this.eventIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'reason': reason,
      'assignedPetIds': assignedPetIds,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'earlyNotificationIds': earlyNotificationIds,
      'eventIds': eventIds,
    };
  }

  static BehavioristReminderModel fromMap(Map<String, dynamic> map) {
    final timeParts = map['time'].split(':');
    return BehavioristReminderModel(
      id: map['id'],
      userId: map['userId'],
      reason: map['reason'],
      assignedPetIds: List<String>.from(map['assignedPetIds']),
      date: DateTime.parse(map['date']),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      earlyNotificationIds: List<int>.from(map['earlyNotificationIds'] ?? []),
      eventIds: List<String>.from(map['eventIds'] ?? []),
    );
  }
}
