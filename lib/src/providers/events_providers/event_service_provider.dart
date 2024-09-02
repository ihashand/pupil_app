import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_service_event_model.dart';
import 'package:pet_diary/src/tests/unit/services/events_services/event_service_service.dart';

final eventServiceServiceProvider = Provider<EventServiceService>((ref) {
  return EventServiceService();
});

final eventServicesProvider = StreamProvider<List<EventServiceModel>>((ref) {
  return ref.watch(eventServiceServiceProvider).getServicesEventStream();
});
