import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/data/repositories/water_repository.dart';

final waterRepositoryProvider = FutureProvider<WaterRepository>((_) async {
  return await WaterRepository.create();
});

final waterNameControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final waterControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final waterDateControllerProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});
