import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/psychic_model.dart';
import 'package:pet_diary/src/services/psychic_event_servie.dart';

final psychicEventServiceProvider = Provider((ref) {
  return PsychicEventService();
});

final psychicEventsProvider = StreamProvider<List<PsychicEvent>>((ref) {
  return ref.watch(psychicEventServiceProvider).getPsychicEventsStream();
});
