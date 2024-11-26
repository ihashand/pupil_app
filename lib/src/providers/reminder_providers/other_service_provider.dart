import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/services/reminders_services/other_reminder_service.dart';

final otherReminderServiceProvider = Provider<OtherReminderService>(
  (_) => OtherReminderService(),
);
