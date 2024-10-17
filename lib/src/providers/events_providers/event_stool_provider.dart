import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/services/events_services/event_stool_service.dart';

final eventStoolServiceProvider = Provider((ref) {
  return EventStoolService();
});
