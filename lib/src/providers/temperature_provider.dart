import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/data/services/temperature_service.dart';

final temperatureServiceProvider = Provider((ref) {
  return TemperatureService();
});

final temperatureNameControllerProvider =
    Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final temperatureControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});
