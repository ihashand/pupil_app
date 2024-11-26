import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/services/reminders_services/behaviorist_reminder_service.dart';

final behavioristReminderServiceProvider = Provider<BehavioristReminderService>(
  (_) => BehavioristReminderService(),
);
