import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/data/services/events_service.dart';

final eventServiceProvider = Provider((ref) {
  return EventService();
});

final eventDateControllerProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});
