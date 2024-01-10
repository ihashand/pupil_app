import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/event_repository.dart';

final eventRepositoryProvider = FutureProvider<EventRepository>((_) async {
  return await EventRepository.create();
});

final eventNameControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final eventDescriptionControllerProvider =
    Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final eventSelectedAvatarProvider = StateProvider<String>((ref) {
  return 'assets/images/dog_avatar_01.png';
});

final eventDateControllerProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});
