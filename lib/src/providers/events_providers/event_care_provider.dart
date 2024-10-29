import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/services/events_services/event_care_service.dart';

final eventCareServiceProvider = Provider<EventCareService>((ref) {
  return EventCareService();
});
