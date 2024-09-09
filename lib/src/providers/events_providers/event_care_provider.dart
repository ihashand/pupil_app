import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_care_model.dart';
import 'package:pet_diary/src/services/events_services/event_care_service.dart';

final eventCareServiceProvider = Provider<EventCareService>((ref) {
  return EventCareService();
});

final eventCaresProvider = StreamProvider<List<EventCareModel>>((ref) {
  return ref.watch(eventCareServiceProvider).getCaresStream();
});
