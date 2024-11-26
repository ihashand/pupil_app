import 'package:flutter/material.dart';

/// Model for grooming reminders.
class GroomingReminderModel {
  final String id;
  final String userId;
  final String reason;
  final List<String> assignedPetIds;
  final DateTime date;
  final TimeOfDay time;
  final List<int> earlyNotificationIds;

  GroomingReminderModel({
    required this.id,
    required this.userId,
    required this.reason,
    required this.assignedPetIds,
    required this.date,
    required this.time,
    this.earlyNotificationIds = const [],
  });

  /// Create a modified copy of the current instance.
  GroomingReminderModel copyWith({
    String? id,
    String? userId,
    String? reason,
    List<String>? assignedPetIds,
    DateTime? date,
    TimeOfDay? time,
    List<int>? earlyNotificationIds,
  }) {
    return GroomingReminderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      reason: reason ?? this.reason,
      assignedPetIds: assignedPetIds ?? this.assignedPetIds,
      date: date ?? this.date,
      time: time ?? this.time,
      earlyNotificationIds: earlyNotificationIds ?? this.earlyNotificationIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'reason': reason,
      'assignedPetIds': assignedPetIds,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'earlyNotificationIds': earlyNotificationIds,
    };
  }

  static GroomingReminderModel fromMap(Map<String, dynamic> map) {
    final timeParts = map['time'].split(':');
    return GroomingReminderModel(
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
    );
  }
}
