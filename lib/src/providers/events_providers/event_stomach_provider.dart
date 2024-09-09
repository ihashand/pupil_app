import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_stomach_model.dart';
import 'package:pet_diary/src/services/events_services/event_stomach_service.dart';

final eventStomachServiceProvider = Provider((ref) {
  return EventStomachService();
});

final eventStomachProvider = StreamProvider<List<EventStomachModel>>((ref) {
  return ref.watch(eventStomachServiceProvider).getStomachStream();
});
