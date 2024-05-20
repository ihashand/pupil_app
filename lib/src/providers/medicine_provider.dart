import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/data/services/pill_service.dart';

final medicineServiceProvider = Provider((ref) {
  return PillService();
});

final medicineNameControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final medicineDateControllerProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final medicineStartDateControllerProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final medicineEndDateControllerProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final medicineFrequencyProvider = StateProvider<int?>((ref) => null);

final medicineDosageProvider = StateProvider<int?>((ref) => null);

final medicineRemindersEnabledProvider = StateProvider<bool>((ref) => false);

final medicineEmojiProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});
