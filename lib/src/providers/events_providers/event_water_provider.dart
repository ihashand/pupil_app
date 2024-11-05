import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_water_model.dart';
import 'package:pet_diary/src/services/events_services/event_water_service.dart';

// Serwis dostarczający EventWaterService
final eventWaterServiceProvider = Provider<EventWaterService>((ref) {
  return EventWaterService();
});

// StreamProvider dla strumienia eventów wody
final eventWaterStreamProvider =
    StreamProvider.family<List<EventWaterModel>, String>((ref, petId) {
  return ref.read(eventWaterServiceProvider).getWatersStream(petId);
});

// Kontroler nazwy dla eventu wody
final eventWaterNameControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
  return TextEditingController();
});

// Kontroler dla ilości eventu wody
final eventWaterControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
  return TextEditingController();
});

// Kontroler daty dla eventu wody
final eventWaterDateControllerProvider =
    StateProvider.autoDispose<DateTime>((ref) {
  return DateTime.now();
});
