import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/services/reminder_service.dart';
import 'package:pet_diary/src/models/reminder_model.dart';

final reminderServiceProvider = Provider((ref) {
  return ReminderService();
});

final reminderNameControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final reminderDescriptionControllerProvider =
    Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final reminderTimeOfDayControllerProvider = StateProvider<TimeOfDay>((ref) {
  return TimeOfDay.now();
});

final reminderSelectedRepeatType = StateProvider<String>((ref) {
  return 'Once';
});

final temporaryReminderIds = StateProvider<List<String>?>((ref) {
  return [];
});

final remindersProvider = StreamProvider<List<Reminder>>((ref) {
  return ReminderService().getRemindersStream();
});
