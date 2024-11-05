import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_stool_model.dart';
import 'package:pet_diary/src/services/events_services/event_stool_service.dart';

// Provider serwisu EventStoolService
final eventStoolServiceProvider = Provider<EventStoolService>((ref) {
  final service = EventStoolService();
  ref.onDispose(() => service
      .dispose()); // Zapewnia czyszczenie zasobów przy zamknięciu providera
  return service;
});

// Provider strumienia wydarzeń typu "stool"
final stoolEventsProvider = StreamProvider<List<EventStoolModel>>((ref) {
  return ref.watch(eventStoolServiceProvider).getStoolEventsStream();
});
