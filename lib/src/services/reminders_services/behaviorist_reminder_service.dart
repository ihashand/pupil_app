import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/reminder_models/behaviorist_reminder_model.dart';

/// Service to manage behaviorist reminders.
class BehavioristReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // StreamController for real-time reminders stream
  final StreamController<List<BehavioristReminderModel>> _reminderController =
      StreamController<List<BehavioristReminderModel>>.broadcast();

  // Cache for fetched reminders to optimize performance
  List<BehavioristReminderModel>? _cachedReminders;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  // List of active subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Fetch behaviorist reminders for the logged-in user as a stream.
  Stream<List<BehavioristReminderModel>> getBehavioristReminders(
      String userId) {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    try {
      if (_cachedReminders != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        _reminderController.add(_cachedReminders!);
      } else {
        final subscription = _firestore
            .collection('behavioristReminders')
            .where('userId', isEqualTo: userId)
            .snapshots()
            .listen((snapshot) {
          final reminders = snapshot.docs.map((doc) {
            return BehavioristReminderModel.fromMap(doc.data());
          }).toList();

          reminders.sort((a, b) => a.date.compareTo(b.date));
          _cachedReminders = reminders;
          _lastFetchTime = DateTime.now();
          _reminderController.add(reminders);
        }, onError: (error) {
          debugPrint('Error fetching behaviorist reminders: $error');
          _reminderController.addError(error);
        });

        _subscriptions.add(subscription);
      }

      return _reminderController.stream;
    } catch (e) {
      debugPrint('Error in getBehavioristReminders: $e');
      return Stream.error(e);
    }
  }

  /// Add a new behaviorist reminder.
  Future<void> addBehavioristReminder(BehavioristReminderModel reminder) async {
    try {
      await _firestore
          .collection('behavioristReminders')
          .doc(reminder.id)
          .set(reminder.toMap());
      _cachedReminders = null; // Invalidate cache after adding
    } catch (e) {
      debugPrint('Error adding behaviorist reminder: $e');
      throw Exception('Failed to add behaviorist reminder');
    }
  }

  /// Update additional notification IDs for a specific reminder.
  Future<void> updateAdditionalNotificationIds(
      String reminderId, List<int> notificationIds) async {
    try {
      await _firestore
          .collection('behavioristReminders')
          .doc(reminderId)
          .update({'additionalNotificationIds': notificationIds});
      _cachedReminders = null; // Invalidate cache after updating
    } catch (e) {
      debugPrint('Error updating additional notification IDs: $e');
      throw Exception('Failed to update additional notification IDs');
    }
  }

  /// Delete a behaviorist reminder by ID.
  Future<void> deleteBehavioristReminder(String reminderId) async {
    try {
      await _firestore
          .collection('behavioristReminders')
          .doc(reminderId)
          .delete();
      _cachedReminders = null; // Invalidate cache after deletion
    } catch (e) {
      debugPrint('Error deleting behaviorist reminder: $e');
      throw Exception('Failed to delete behaviorist reminder');
    }
  }

  /// Dispose the service to clean up resources.
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _reminderController.close();
  }
}
