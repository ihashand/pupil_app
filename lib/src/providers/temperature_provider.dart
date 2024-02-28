import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/data/repositories/temperature_repository.dart';

final temperatureRepositoryProvider =
    FutureProvider<TemperatureRepository>((_) async {
  return await TemperatureRepository.create();
});

final temperatureNameControllerProvider =
    Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final temperatureControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});
