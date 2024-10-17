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

final eventWalksProviderStream = StreamProvider<List<EventWalkModel?>>((ref) {
  return EventWalkService().getWalksStream();
});

final StreamProviderFamily<List<EventWalkModel>, String> eventWalksProvider =
    StreamProvider.family<List<EventWalkModel>, String>((ref, petId) {
  return EventWalkService().getWalksForUserPet(petId);
});

final StreamProviderFamily<List<EventWalkModel>, Map<String, String>>
    eventWalksProviderFamily =
    StreamProvider.family<List<EventWalkModel>, Map<String, String>>(
        (ref, params) {
  final userId = params['userId'];
  final petId = params['petId'];

  if (userId == null || userId.isEmpty || petId == null || petId.isEmpty) {
    return Stream.value([]);
  }

  return EventWalkService().getWalksForPet(userId, petId);
});
