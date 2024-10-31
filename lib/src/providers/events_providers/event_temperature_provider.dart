import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/services/events_services/event_temperature_service.dart';
import 'package:pet_diary/src/models/events_models/event_temperature_model.dart';

// Provider dla serwisu temperatur
final eventTemperatureServiceProvider = Provider((ref) {
  return EventTemperatureService();
});

// StreamProvider do obserwowania zmian temperatur dla konkretnego użytkownika
final eventTemperaturesStreamProvider =
    StreamProvider.autoDispose<List<EventTemperatureModel>>((ref) {
  return ref.read(eventTemperatureServiceProvider).getTemperatureStream();
});

// FutureProvider do jednokrotnego pobrania danych o temperaturze
final eventTemperaturesOnceProvider =
    FutureProvider.autoDispose<List<EventTemperatureModel>>((ref) async {
  return ref.read(eventTemperatureServiceProvider).getTemperaturesOnce();
});

// Provider do kontrolera dla pola nazwy temperatury
final eventTemperatureNameControllerProvider =
    Provider<TextEditingController>((ref) {
  return TextEditingController();
});

// Provider do kontrolera dla wartości temperatury
final eventTemperatureControllerProvider =
    Provider<TextEditingController>((ref) {
  return TextEditingController();
});
