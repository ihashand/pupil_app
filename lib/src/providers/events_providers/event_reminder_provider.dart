import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/services/event_reminder_service.dart';
import 'package:pet_diary/src/models/events_models/event_reminder_model.dart';

final eventReminderServiceProvider = Provider((ref) {
  return EventReminderService();
});

final eventReminderNameControllerProvider =
    Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final eventReminderDescriptionControllerProvider =
    Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final eventReminderTimeOfDayControllerProvider =
    StateProvider<TimeOfDay>((ref) {
  return TimeOfDay.now();
});

final eventReminderSelectedRepeatType = StateProvider<String>((ref) {
  return 'Once';
});

final eventReminderTemporaryIds = StateProvider<List<String>?>((ref) {
  return [];
});

final eventRemindersProvider = StreamProvider<List<EventReminderModel>>((ref) {
  return EventReminderService().getRemindersStream();
});
