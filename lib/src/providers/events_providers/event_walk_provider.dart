import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/services/event_walk_service.dart';
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

final eventWalksProvider = StreamProvider<List<EventWalkModel?>>((ref) {
  return EventWalkService().getWalksStream();
});

final eventWalksFriendProvider =
    StreamProvider.family<List<EventWalkModel>, String>((ref, id) {
  return EventWalkService().getWalksFriend(id);
});
