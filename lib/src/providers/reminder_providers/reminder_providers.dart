import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/reminder_models/feed_reminder_settings_model.dart';
import 'package:pet_diary/src/models/reminder_models/reminder_model.dart';
import 'package:pet_diary/src/services/reminders_services/reminder_servcie.dart';

// Provider dla serwisu przypomnień
final reminderServiceProvider = Provider((ref) {
  return ReminderService();
});

// StreamProvider do obserwowania zmian przypomnień dla użytkownika
final remindersStreamProvider =
    StreamProvider.autoDispose<List<ReminderModel>>((ref) {
  return ref.read(reminderServiceProvider).getReminderStream();
});

// FutureProvider do jednokrotnego pobrania danych o przypomnieniach
final remindersOnceProvider =
    FutureProvider.autoDispose<List<ReminderModel>>((ref) async {
  return ref.read(reminderServiceProvider).getRemindersOnce();
});

// Provider do kontrolera dla pola nazwy przypomnienia
final reminderNameControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

// Provider do kontrolera dla daty przypomnienia
final reminderDateControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final feedReminderSettingsProvider =
    FutureProvider.family<FeedReminderSettingsModel?, String>((ref, userId) {
  return ref.read(reminderServiceProvider).getFeedReminderSettings(userId);
});
