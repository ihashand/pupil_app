import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WalkReminderSettingsModel {
  String id;
  String userId;
  bool globalIsActive;
  List<ReminderSetting> reminders;

  WalkReminderSettingsModel({
    required this.id,
    required this.userId,
    required this.globalIsActive,
    required this.reminders,
  });

  WalkReminderSettingsModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        userId = doc.get('userId'),
        globalIsActive = doc.get('globalIsActive'),
        reminders = (doc.get('reminders') as List).map((reminder) {
          return ReminderSetting(
            time: TimeOfDay(
              hour: reminder['time']['hour'],
              minute: reminder['time']['minute'],
            ),
            assignedPetIds: List<String>.from(reminder['assignedPetIds']),
            isActive: reminder['isActive'],
          );
        }).toList();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'globalIsActive': globalIsActive,
      'reminders': reminders.map((reminder) => reminder.toMap()).toList(),
    };
  }
}

class ReminderSetting {
  TimeOfDay time;
  List<String> assignedPetIds;
  bool isActive;

  ReminderSetting({
    required this.time,
    required this.assignedPetIds,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'time': {'hour': time.hour, 'minute': time.minute},
      'assignedPetIds': assignedPetIds,
      'isActive': isActive,
    };
  }
}
