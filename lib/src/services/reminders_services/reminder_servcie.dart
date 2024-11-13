import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/reminder_models/feed_reminder_settings_model.dart';
import 'package:pet_diary/src/models/reminder_models/reminder_model.dart';

/// A service class responsible for handling reminder-related operations.
///
/// This class provides methods to create, update, delete, and retrieve reminders.
/// It interacts with the underlying data storage to persist reminder information.
class ReminderService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final Duration _cacheDuration = const Duration(minutes: 5);

  FeedReminderSettingsModel? _cachedFeedReminderSettings;
  DateTime? _lastFetchTime;
  final _reminderController = StreamController<List<ReminderModel>>.broadcast();

  Future<List<ReminderModel>> getRemindersByEventId(String eventId) async {
    if (_currentUser == null) {
      return [];
    }

    final querySnapshot = await _firestore
        .collection('reminders')
        .where('userId', isEqualTo: _currentUser.uid)
        .where('eventId', isEqualTo: eventId)
        .get();

    return querySnapshot.docs
        .map((doc) => ReminderModel.fromDocument(doc))
        .toList();
  }

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

  // Włączanie/wyłączanie przypomnienia dla wybranej godziny
  Future<void> toggleIndividualReminder(TimeOfDay time, bool isActive) async {
    final settings = await getFeedReminderSettings(_currentUser!.uid);
    if (settings != null) {
      final reminder = settings.reminders.firstWhere(
        (r) => r.time.hour == time.hour && r.time.minute == time.minute,
        orElse: () =>
            ReminderSetting(time: time, assignedPetIds: [], isActive: isActive),
      );
      reminder.isActive = isActive;
      await saveFeedReminderSettings(settings);
    }
  }

  // Dodanie przypomnienia
  Future<void> addReminder(ReminderModel reminder) async {
    await _firestore
        .collection('reminders')
        .doc(reminder.id)
        .set(reminder.toMap());
    _cachedFeedReminderSettings = null;
  }

  // Aktualizacja przypomnienia
  Future<void> updateReminder(ReminderModel reminder) async {
    await _firestore
        .collection('reminders')
        .doc(reminder.id)
        .update(reminder.toMap());
    _cachedFeedReminderSettings = null;
  }

  // Usunięcie przypomnienia
  Future<void> deleteReminder(String reminderId) async {
    await _firestore.collection('reminders').doc(reminderId).delete();
    _cachedFeedReminderSettings = null;
  }

  // Strumień przypomnień dla użytkownika
  Stream<List<ReminderModel>> getReminderStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }
    _firestore
        .collection('reminders')
        .where('userId', isEqualTo: _currentUser.uid)
        .snapshots()
        .listen((snapshot) {
      _reminderController.add(
          snapshot.docs.map((doc) => ReminderModel.fromDocument(doc)).toList());
    });

    return _reminderController.stream;
  }

  // Pobranie przypomnień jednorazowo z cache lub bazy
  Future<List<ReminderModel>> getRemindersOnce() async {
    if (_cachedFeedReminderSettings != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedFeedReminderSettings!.reminders
          .map((reminder) => ReminderModel(
                id: reminder.time.toString(),
                name: 'Feed Reminder',
                petId: '',
                userId: _currentUser!.uid,
                scheduledDate: DateTime.now(), // Adjust if needed
                emoji: '🐾',
                isActive: reminder.isActive,
                notificationId: reminder.time.hashCode,
              ))
          .toList();
    }

    if (_currentUser == null) {
      return [];
    }

    final querySnapshot = await _firestore
        .collection('reminders')
        .where('userId', isEqualTo: _currentUser.uid)
        .get();

    final reminders = querySnapshot.docs
        .map((doc) => ReminderModel.fromDocument(doc))
        .toList();

    _cachedFeedReminderSettings = FeedReminderSettingsModel(
      id: _currentUser.uid,
      userId: _currentUser.uid,
      globalIsActive: true,
      reminders: reminders
          .map((r) => ReminderSetting(
                time: TimeOfDay(
                    hour: r.scheduledDate.hour, minute: r.scheduledDate.minute),
                assignedPetIds: [r.petId], // adjust based on data structure
                isActive: r.isActive,
              ))
          .toList(),
    );
    _lastFetchTime = DateTime.now();

    return reminders;
  }

  void dispose() {
    _reminderController.close();
  }
}
