import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/event_feeding_service.dart';

final eventFeedingServiceProvider = Provider((ref) {
  return EventFeedingService();
});

final feedingsProvider = FutureProvider((ref) async {
  final feedingService = ref.watch(eventFeedingServiceProvider);
  return feedingService.getFeedings();
});
