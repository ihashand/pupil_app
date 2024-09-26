import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/services/events_services/event_type_service.dart';

final eventTypeServiceProvider = Provider<EventTypeService>((ref) {
  return EventTypeService();
});
