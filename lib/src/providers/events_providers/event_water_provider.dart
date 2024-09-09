import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/services/events_services/event_water_service.dart';

final eventWaterServiceProvider = Provider((ref) {
  return EventWaterService();
});

final eventWaterNameControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final eventWaterControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final eventWaterDateControllerProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});
