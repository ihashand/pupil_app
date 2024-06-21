import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/event_mood_model.dart';
import 'package:pet_diary/src/services/event_mood_service.dart';

final eventMoodServiceProvider = Provider((ref) {
  return EventMoodService();
});

final eventMoodsProvider = StreamProvider<List<EventMoodModel>>((ref) {
  return ref.watch(eventMoodServiceProvider).getMoodsStream();
});
