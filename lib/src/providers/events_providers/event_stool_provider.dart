import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_stool_model.dart';
import 'package:pet_diary/src/services/event_stool_service.dart';

final eventStoolServiceProvider = Provider((ref) {
  return EventStoolService();
});

final eventStoolProvider = StreamProvider<List<EventStoolModel>>((ref) {
  return ref.watch(eventStoolServiceProvider).getStoolEventsStream();
});
