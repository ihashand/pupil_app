import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/data/repositories/reminder_repository.dart';

final reminderRepositoryProvider =
    FutureProvider<ReminderRepository>((_) async {
  return await ReminderRepository.create();
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
