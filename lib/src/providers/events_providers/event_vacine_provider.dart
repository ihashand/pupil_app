import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_vacine_model.dart';
import 'package:pet_diary/services/events_services/event_vacine_service.dart';

final eventVaccineServiceProvider = Provider((ref) {
  return VaccineService();
});

final eventVaccineProvider = StreamProvider<List<EventVaccineModel>>((ref) {
  return ref.watch(eventVaccineServiceProvider).getVaccineStream();
});
