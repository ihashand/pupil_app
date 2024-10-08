import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/services/events_services/event_walk_service.dart';
import 'package:pet_diary/src/models/events_models/event_walk_model.dart';

final eventWalkServiceProvider = Provider((ref) {
  return EventWalkService();
});

final eventWalkNameControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final eventWalkControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final eventWalkDateControllerProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final eventWalksProviderFamily =
    StreamProvider.family<List<EventWalkModel?>, List<String>>((ref, params) {
  final userId = params[0];
  final petId = params[1];
  return ref.read(eventWalkServiceProvider).getWalksForPet(userId, petId);
});

final eventWalksProviderStream = StreamProvider<List<EventWalkModel?>>((ref) {
  return EventWalkService().getWalksStream();
});
