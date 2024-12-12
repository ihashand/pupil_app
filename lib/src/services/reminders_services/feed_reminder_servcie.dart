import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/reminder_models/feed_reminder_settings_model.dart';

/// A service class responsible for handling Feed Reminder operations.
class FeedReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final Duration _cacheDuration = const Duration(minutes: 5);

  FeedReminderSettingsModel? _cachedFeedReminderSettings;
  DateTime? _lastFetchTime;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _settingsSubscription;
  final StreamController<FeedReminderSettingsModel?> _settingsController =
      StreamController<FeedReminderSettingsModel?>.broadcast();

  /// Fetch Feed Reminder Settings with caching.
  Future<FeedReminderSettingsModel?> getFeedReminderSettings(
      String userId) async {
    if (_cachedFeedReminderSettings != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedFeedReminderSettings;
    }

    try {
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
    } catch (e) {
      print('Error fetching feed reminder settings: $e');
      return null;
    }
  }

  /// Save Feed Reminder Settings and update the cache.
  Future<void> saveFeedReminderSettings(
      FeedReminderSettingsModel settings) async {
    try {
      await _firestore
          .collection('feedReminders')
          .doc(settings.id)
          .set(settings.toMap());
      _cachedFeedReminderSettings = settings;
      _lastFetchTime = DateTime.now();
    } catch (e) {
      print('Error saving feed reminder settings: $e');
      throw Exception('Failed to save feed reminder settings');
    }
  }

  /// Toggle the global reminder activation state.
  Future<void> toggleGlobalReminder(bool isActive) async {
    try {
      final settings = await getFeedReminderSettings(_currentUser!.uid);
      if (settings != null) {
        settings.globalIsActive = isActive;
        for (var reminder in settings.reminders) {
          reminder.isActive = isActive;
        }
        await saveFeedReminderSettings(settings);
      }
    } catch (e) {
      print('Error toggling global reminder: $e');
      throw Exception('Failed to toggle global reminder');
    }
  }

  /// Subscribe to changes in the Feed Reminder Settings.
  Stream<FeedReminderSettingsModel?> subscribeToFeedReminderSettings(
      String userId) {
    _settingsSubscription = _firestore
        .collection('feedReminders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final settings =
            FeedReminderSettingsModel.fromDocument(snapshot.docs.first);
        _cachedFeedReminderSettings = settings;
        _lastFetchTime = DateTime.now();
        _settingsController.add(settings);
      } else {
        _settingsController.add(null);
      }
    }, onError: (error) {
      print('Error subscribing to feed reminder settings: $error');
      _settingsController.addError(error);
    });

    return _settingsController.stream;
  }

  /// Cancel the active subscription.
  void cancelSubscription() {
    _settingsSubscription?.cancel();
  }

  /// Dispose the settings stream controller.
  void dispose() {
    cancelSubscription();
    _settingsController.close();
  }
}
