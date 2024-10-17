import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/services/events_services/event_walk_events_service.dart';

final eventWalkEventsServiceProvider = Provider((ref) {
  return EventWalkEventsService();
});
