import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/event_psychic_model.dart';
import 'package:pet_diary/src/services/event_psychic_servie.dart';

final eventPsychicServiceProvider = Provider((ref) {
  return EventPsychicService();
});

final eventsPsychicProvider = StreamProvider<List<EventPsychicModel>>((ref) {
  return ref.watch(eventPsychicServiceProvider).getPsychicEventsStream();
});
