import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/reminder_models/walk_reminder_settings_model.dart';

/// A service class responsible for handling Walk Reminder operations.
class WalkReminderService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final Duration _cacheDuration = const Duration(minutes: 5);

  WalkReminderSettingsModel? _cachedWalkReminderSettings;
  DateTime? _lastFetchTime;

  // Pobranie ustawień przypomnień dla spacerów z cache lub bazy
  Future<WalkReminderSettingsModel?> getWalkReminderSettings(
      String userId) async {
    if (_cachedWalkReminderSettings != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedWalkReminderSettings;
    }

    final querySnapshot = await _firestore
        .collection('walkReminders')
        .where('userId', isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      _cachedWalkReminderSettings =
          WalkReminderSettingsModel.fromDocument(querySnapshot.docs.first);
      _lastFetchTime = DateTime.now();
      return _cachedWalkReminderSettings;
    } else {
      return null;
    }
  }

  // Zapisz ustawienia przypomnień dla spacerów i zaktualizuj cache
  Future<void> saveWalkReminderSettings(
      WalkReminderSettingsModel settings) async {
    await _firestore
        .collection('walkReminders')
        .doc(settings.id)
        .set(settings.toMap());
    _cachedWalkReminderSettings = settings;
    _lastFetchTime = DateTime.now();
  }

  // Włączanie/wyłączanie wszystkich przypomnień
  Future<void> toggleGlobalReminder(bool isActive) async {
    final settings = await getWalkReminderSettings(_currentUser!.uid);
    if (settings != null) {
      settings.globalIsActive = isActive;
      for (var reminder in settings.reminders) {
        reminder.isActive = isActive;
      }
      await saveWalkReminderSettings(settings);
    }
  }
}
