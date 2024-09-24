import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/services/events_services/events_service.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';

final eventServiceProvider = Provider((ref) {
  return EventService();
});

final eventDateControllerProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final eventsProvider = StreamProvider.family<List<Event>, String>((ref, petId) {
  return ref.watch(eventServiceProvider).getEventsStream(petId);
});
