import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/reminder_models/other_reminder_model.dart';

/// Service to manage other reminders.
class OtherReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Cache and subscription management
  List<OtherReminderModel>? _cachedReminders;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);
  final StreamController<List<OtherReminderModel>> _reminderController =
      StreamController<List<OtherReminderModel>>.broadcast();
  final List<StreamSubscription> _subscriptions = [];

  /// Fetch other reminders for the logged-in user as a stream.
  Stream<List<OtherReminderModel>> getOtherReminders(String userId) {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    final subscription = _firestore
        .collection('otherReminders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      final reminders = snapshot.docs.map((doc) {
        return OtherReminderModel.fromMap(doc.data());
      }).toList();

      reminders.sort((a, b) => a.date.compareTo(b.date));
      _cachedReminders = reminders;
      _lastFetchTime = DateTime.now();
      _reminderController.add(reminders);
    }, onError: (error) {
      debugPrint('Error fetching other reminders: $error');
      _reminderController.addError(error);
    });

    _subscriptions.add(subscription);
    return _reminderController.stream;
  }

  /// Fetch other reminders with caching for a one-time operation.
  Future<List<OtherReminderModel>> getOtherRemindersOnce(String userId) async {
    if (_cachedReminders != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedReminders!;
    }

    try {
      final querySnapshot = await _firestore
          .collection('otherReminders')
          .where('userId', isEqualTo: userId)
          .get();

      final reminders = querySnapshot.docs.map((doc) {
        return OtherReminderModel.fromMap(doc.data());
      }).toList();

      reminders.sort((a, b) => a.date.compareTo(b.date));
      _cachedReminders = reminders;
      _lastFetchTime = DateTime.now();
      return reminders;
    } catch (e) {
      debugPrint('Error fetching other reminders: $e');
      throw Exception('Failed to fetch other reminders');
    }
  }

  /// Add a new other reminder.
  Future<void> addOtherReminder(OtherReminderModel reminder) async {
    try {
      await _firestore
          .collection('otherReminders')
          .doc(reminder.id)
          .set(reminder.toMap());
      _cachedReminders = null; // Invalidate cache
    } catch (e) {
      debugPrint('Error adding other reminder: $e');
      throw Exception('Failed to add other reminder');
    }
  }

  /// Update additional notification IDs for a specific reminder.
  Future<void> updateAdditionalNotificationIds(
      String reminderId, List<int> notificationIds) async {
    try {
      await _firestore.collection('otherReminders').doc(reminderId).update({
        'additionalNotificationIds': notificationIds,
      });
      _cachedReminders = null; // Invalidate cache
    } catch (e) {
      debugPrint('Error updating notification IDs: $e');
      throw Exception('Failed to update notification IDs');
    }
  }

  /// Delete an other reminder by ID.
  Future<void> deleteOtherReminder(String reminderId) async {
    try {
      await _firestore.collection('otherReminders').doc(reminderId).delete();
      _cachedReminders = null; // Invalidate cache
    } catch (e) {
      debugPrint('Error deleting other reminder: $e');
      throw Exception('Failed to delete other reminder');
    }
  }

  /// Cancel all active subscriptions.
  void cancelAllSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// Dispose the reminder stream controller.
  void dispose() {
    cancelAllSubscriptions();
    _reminderController.close();
  }
}
