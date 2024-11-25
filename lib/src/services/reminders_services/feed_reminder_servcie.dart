import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/reminder_models/feed_reminder_settings_model.dart';

/// A service class responsible for handling Feed Reminder operations.
class FeedReminderService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final Duration _cacheDuration = const Duration(minutes: 5);

  FeedReminderSettingsModel? _cachedFeedReminderSettings;
  DateTime? _lastFetchTime;

  // Pobranie ustawień przypomnień dla karmienia z cache lub bazy
  Future<FeedReminderSettingsModel?> getFeedReminderSettings(
      String userId) async {
    if (_cachedFeedReminderSettings != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedFeedReminderSettings;
    }

    final querySnapshot = await _firestore
        .collection('feedReminders')
        .where('userId', isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      _cachedFeedReminderSettings =
          FeedReminderSettingsModel.fromDocument(querySnapshot.docs.first);
      _lastFetchTime = DateTime.now();
      return _cachedFeedReminderSettings;
    } else {
      return null;
    }
  }

  // Zapisz ustawienia przypomnień dla karmienia i zaktualizuj cache
  Future<void> saveFeedReminderSettings(
      FeedReminderSettingsModel settings) async {
    await _firestore
        .collection('feedReminders')
        .doc(settings.id)
        .set(settings.toMap());
    _cachedFeedReminderSettings = settings;
    _lastFetchTime = DateTime.now();
  }

  // Włączanie/wyłączanie wszystkich przypomnień
  Future<void> toggleGlobalReminder(bool isActive) async {
    final settings = await getFeedReminderSettings(_currentUser!.uid);
    if (settings != null) {
      settings.globalIsActive = isActive;
      for (var reminder in settings.reminders) {
        reminder.isActive = isActive;
      }
      await saveFeedReminderSettings(settings);
    }
  }
}
