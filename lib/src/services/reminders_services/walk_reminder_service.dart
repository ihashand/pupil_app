import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/reminder_models/walk_reminder_settings_model.dart';

/// A service class responsible for handling Walk Reminder operations.
class WalkReminderService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final Duration _cacheDuration = const Duration(minutes: 5);

  WalkReminderSettingsModel? _cachedWalkReminderSettings;
  DateTime? _lastFetchTime;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _settingsSubscription;
  final StreamController<WalkReminderSettingsModel?> _settingsController =
      StreamController<WalkReminderSettingsModel?>.broadcast();

  /// Fetch walk reminder settings from cache or Firestore.
  Future<WalkReminderSettingsModel?> getWalkReminderSettings(
      String userId) async {
    if (_cachedWalkReminderSettings != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedWalkReminderSettings;
    }

    try {
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
    } catch (e) {
      debugPrint('Error fetching walk reminder settings: $e');
      return null;
    }
  }

  /// Save walk reminder settings and update the cache.
  Future<void> saveWalkReminderSettings(
      WalkReminderSettingsModel settings) async {
    try {
      await _firestore
          .collection('walkReminders')
          .doc(settings.id)
          .set(settings.toMap());
      _cachedWalkReminderSettings = settings;
      _lastFetchTime = DateTime.now();
    } catch (e) {
      debugPrint('Error saving walk reminder settings: $e');
    }
  }

  /// Toggle the global reminder activation state.
  Future<void> toggleGlobalReminder(bool isActive) async {
    try {
      final settings = await getWalkReminderSettings(_currentUser!.uid);
      if (settings != null) {
        settings.globalIsActive = isActive;
        for (var reminder in settings.reminders) {
          reminder.isActive = isActive;
        }
        await saveWalkReminderSettings(settings);
      }
    } catch (e) {
      debugPrint('Error toggling global reminder: $e');
    }
  }

  /// Subscribe to changes in the walk reminder settings in Firestore.
  Stream<WalkReminderSettingsModel?> subscribeToWalkReminderSettings(
      String userId) {
    if (_currentUser == null) {
      return Stream.value(null);
    }

    _settingsSubscription = _firestore
        .collection('walkReminders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final settings =
            WalkReminderSettingsModel.fromDocument(querySnapshot.docs.first);
        _cachedWalkReminderSettings = settings;
        _lastFetchTime = DateTime.now();
        _settingsController.add(settings);
      } else {
        _settingsController.add(null);
      }
    }, onError: (error) {
      debugPrint('Error subscribing to walk reminder settings: $error');
      _settingsController.addError(error);
    });

    return _settingsController.stream;
  }

  /// Cancel the active subscription and clean up resources.
  void cancelSubscription() {
    _settingsSubscription?.cancel();
  }

  /// Dispose the service by closing the stream controller.
  void dispose() {
    cancelSubscription();
    _settingsController.close();
  }
}
