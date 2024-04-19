import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/data/services/pill_service.dart';

final pillServiceProvider = Provider((ref) {
  return PillService();
});

final pillNameControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final pillDateControllerProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final pillStartDateControllerProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final pillEndDateControllerProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final pillFrequencyProvider = StateProvider<int?>((ref) => null);

final pillDosageProvider = StateProvider<int?>((ref) => null);

final pillRemindersEnabledProvider = StateProvider<bool>((ref) => false);

final pillEmojiProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});
