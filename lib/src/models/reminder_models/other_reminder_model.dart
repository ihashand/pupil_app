import 'package:flutter/material.dart';

/// Model for other reminders.
class OtherReminderModel {
  final String id;
  final String userId;
  final String reason;
  final List<String> assignedPetIds;
  final DateTime date;
  final TimeOfDay time;
  final List<int> earlyNotificationIds;
  final List<String> eventIds; // IDs of related events

  OtherReminderModel({
    required this.id,
    required this.userId,
    required this.reason,
    required this.assignedPetIds,
    required this.date,
    required this.time,
    required this.earlyNotificationIds,
    required this.eventIds,
  });

  /// Create a modified copy of the current instance.
  OtherReminderModel copyWith({
    String? id,
    String? userId,
    String? reason,
    List<String>? assignedPetIds,
    DateTime? date,
    TimeOfDay? time,
    List<int>? earlyNotificationIds,
    List<String>? eventIds,
  }) {
    return OtherReminderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      reason: reason ?? this.reason,
      assignedPetIds: assignedPetIds ?? this.assignedPetIds,
      date: date ?? this.date,
      time: time ?? this.time,
      earlyNotificationIds: earlyNotificationIds ?? this.earlyNotificationIds,
      eventIds: eventIds ?? this.eventIds,
    );
  }

  /// Convert the model to a map for Firestore storage.
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

  /// Create a model instance from a Firestore map.
  static OtherReminderModel fromMap(Map<String, dynamic> map) {
    final timeParts = map['time'].split(':');
    return OtherReminderModel(
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
