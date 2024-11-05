import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_mood_model.dart';
import 'package:pet_diary/src/services/events_services/event_mood_service.dart';

// Provider dla instancji EventMoodService
final eventMoodServiceProvider = Provider((ref) {
  return EventMoodService();
});

// StreamProvider do strumienia zmian nastrojów w czasie rzeczywistym
final eventMoodsProvider = StreamProvider<List<EventMoodModel>>((ref) {
  return ref.watch(eventMoodServiceProvider).getMoodsStream();
});

// FutureProvider dla jednorazowego pobrania nastrojów z cache
final eventMoodsOnceProvider = FutureProvider<List<EventMoodModel>>((ref) {
  return ref.watch(eventMoodServiceProvider).getMoodsOnce();
});
