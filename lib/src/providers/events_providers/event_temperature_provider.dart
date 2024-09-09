import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/services/events_services/event_temperature_service.dart';

final eventTemperatureServiceProvider = Provider((ref) {
  return EventTemperatureService();
});

final eventTemperatureNameControllerProvider =
    Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final eventTemperatureControllerProvider =
    Provider<TextEditingController>((ref) {
  return TextEditingController();
});
