import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_weight_model.dart';
import '../../services/event_weight_service.dart';

final eventWeightServiceProvider = Provider((ref) {
  return EventWeightService();
});

final eventWeightNameControllerProvider =
    Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final eventWeightControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final eventWeightDateControllerProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final eventWeightsProvider = StreamProvider<List<EventWeightModel?>>((ref) {
  return EventWeightService().getWeightsStream();
});
