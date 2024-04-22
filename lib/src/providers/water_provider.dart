import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/data/services/water_service.dart';

final waterServiceProvider = Provider((ref) {
  return WaterService();
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
