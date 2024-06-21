import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/event_stomach_model.dart';
import 'package:pet_diary/src/services/event_stomach_service.dart';

final eventStomachServiceProvider = Provider((ref) {
  return EventStomachService();
});

final eventStomachProvider = StreamProvider<List<EventStomachModel>>((ref) {
  return ref.watch(eventStomachServiceProvider).getStomachStream();
});
