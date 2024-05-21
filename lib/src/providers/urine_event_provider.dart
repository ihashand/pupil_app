import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/urine_event_model.dart';
import 'package:pet_diary/src/services/urine_event_service.dart';

final urineEventServiceProvider = Provider((ref) {
  return UrineEventService();
});

final urineEventsProvider = StreamProvider<List<UrineEvent>>((ref) {
  return ref.watch(urineEventServiceProvider).getUrineEventsStream();
});
