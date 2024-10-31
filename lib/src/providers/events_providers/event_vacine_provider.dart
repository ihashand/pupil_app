import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_vacine_model.dart';
import 'package:pet_diary/src/services/events_services/event_vacine_service.dart';

final eventVaccineServiceProvider = Provider((ref) {
  return VaccineService();
});

// Provider dla strumienia danych o szczepieniach
final eventVaccineStreamProvider =
    StreamProvider<List<EventVaccineModel>>((ref) {
  return ref.watch(eventVaccineServiceProvider).getVaccineStream();
});

// Provider dla jednorazowego pobrania danych o szczepieniach
final eventVaccineOnceProvider = FutureProvider<List<EventVaccineModel>>((ref) {
  return ref.watch(eventVaccineServiceProvider).getVaccineEventsOnce();
});
