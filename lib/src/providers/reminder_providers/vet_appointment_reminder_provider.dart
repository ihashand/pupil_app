import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/reminder_models/vet_appotiment_reminder_model.dart';
import 'package:pet_diary/src/services/reminders_services/vet_appointment_reminder_service.dart';

final vetAppointmentServiceProvider = Provider<VetAppointmentService>(
  (ref) => VetAppointmentService(),
);

final vetAppointmentsFutureProvider =
    FutureProvider.autoDispose.family<List<VetAppointmentModel>, String>(
  (ref, userId) async {
    return ref
        .read(vetAppointmentServiceProvider)
        .getCachedAppointments(userId);
  },
);

final vetAppointmentsStreamProvider =
    StreamProvider.autoDispose.family<List<VetAppointmentModel>, String>(
  (ref, userId) {
    return ref.read(vetAppointmentServiceProvider).getVetAppointments(userId);
  },
);
