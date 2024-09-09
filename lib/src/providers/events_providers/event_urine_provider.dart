import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_urine_model.dart';
import 'package:pet_diary/src/services/events_services/event_urine_service.dart';

final eventUrineServiceProvider = Provider((ref) {
  return EventUrineService();
});

final eventUrineProvider = StreamProvider<List<EventUrineModel>>((ref) {
  return ref.watch(eventUrineServiceProvider).getUrineEventsStream();
});
