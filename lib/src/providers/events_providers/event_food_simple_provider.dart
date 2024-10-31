import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_food_simple_model.dart';
import 'package:pet_diary/src/services/events_services/event_food_simple_service.dart';

final foodSimpleServiceProvider = Provider((ref) => EventFoodSimpleService());

final foodSimpleStreamProvider =
    StreamProvider.family<List<EventFoodSimpleModel>, String>((ref, petId) {
  return ref.read(foodSimpleServiceProvider).getFoodEventsStream(petId);
});
