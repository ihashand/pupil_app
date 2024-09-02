import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/services/event_medicine_service.dart';
import 'package:pet_diary/src/models/events_models/event_medicine_model.dart';

final eventMedicineServiceProvider = Provider((ref) {
  return EventMedicineService();
});

final eventMedicineNameControllerProvider =
    Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final eventMedicineDateControllerProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final eventMedicineStartDateControllerProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final eventMedicineEndDateControllerProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final eventMedicineFrequencyProvider = StateProvider<int?>((ref) => null);

final eventMedicineDosageProvider = StateProvider<int?>((ref) => null);

final eventMedicineRemindersEnabledProvider =
    StateProvider<bool>((ref) => false);

final eventMedicineEmojiProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final eventMedicinesProvider = StreamProvider<List<EventMedicineModel>>((ref) {
  return EventMedicineService().getPills();
});
