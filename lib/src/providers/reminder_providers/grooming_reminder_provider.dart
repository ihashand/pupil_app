import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/services/reminders_services/grooming_reminder_service.dart';

final groomingReminderServiceProvider = Provider<GroomingReminderService>(
  (ref) => GroomingReminderService(),
);
