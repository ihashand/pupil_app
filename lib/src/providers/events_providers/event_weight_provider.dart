import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_weight_model.dart';
import '../../services/events_services/event_weight_service.dart';

final eventWeightServiceProvider = Provider((ref) => EventWeightService());

final eventWeightsStreamProvider =
    StreamProvider.family<List<EventWeightModel>, String>((ref, petId) {
  return ref.read(eventWeightServiceProvider).getWeightsStream(petId);
});
