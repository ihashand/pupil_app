import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/data/repositories/pill_repository.dart';

final pillRepositoryProvider = FutureProvider<PillRepository>((_) async {
  return await PillRepository.create();
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
