import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/reminder_models/reminder_model.dart';

/// A service class responsible for handling general reminder operations.
class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Cache and subscription management
  List<ReminderModel>? _cachedReminders;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  final StreamController<List<ReminderModel>> _reminderController =
      StreamController<List<ReminderModel>>.broadcast();
  final List<StreamSubscription> _subscriptions = [];

  /// Get reminders by event ID.
  Future<List<ReminderModel>> getRemindersByEventId(String eventId) async {
    if (_currentUser == null) {
      return [];
    }

    try {
      final querySnapshot = await _firestore
          .collection('reminders')
          .where('userId', isEqualTo: _currentUser.uid)
          .where('eventId', isEqualTo: eventId)
          .get();

      return querySnapshot.docs
          .map((doc) => ReminderModel.fromDocument(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching reminders by eventId: $e');
      return [];
    }
  }

  /// Add a new reminder to the database.
  Future<void> addReminder(ReminderModel reminder) async {
    try {
      await _firestore
          .collection('reminders')
          .doc(reminder.id)
          .set(reminder.toMap());
      _cachedReminders = null; // Invalidate cache
    } catch (e) {
      debugPrint('Error adding reminder: $e');
      throw Exception('Failed to add reminder');
    }
  }

  /// Update an existing reminder in the database.
  Future<void> updateReminder(ReminderModel reminder) async {
    try {
      await _firestore
          .collection('reminders')
          .doc(reminder.id)
          .update(reminder.toMap());
      _cachedReminders = null; // Invalidate cache
    } catch (e) {
      debugPrint('Error updating reminder: $e');
      throw Exception('Failed to update reminder');
    }
  }

  /// Delete a reminder from the database.
  Future<void> deleteReminder(String reminderId) async {
    try {
      await _firestore.collection('reminders').doc(reminderId).delete();
      _cachedReminders = null; // Invalidate cache
    } catch (e) {
      debugPrint('Error deleting reminder: $e');
      throw Exception('Failed to delete reminder');
    }
  }

  /// Get a stream of reminders for the current user.
  Stream<List<ReminderModel>> getReminderStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    final subscription = _firestore
        .collection('reminders')
        .where('userId', isEqualTo: _currentUser.uid)
        .snapshots()
        .listen((snapshot) {
      final reminders =
          snapshot.docs.map((doc) => ReminderModel.fromDocument(doc)).toList();

      _cachedReminders = reminders;
      _lastFetchTime = DateTime.now();
      _reminderController.add(reminders);
    }, onError: (error) {
      debugPrint('Error in reminder stream: $error');
      _reminderController.addError(error);
    });

    _subscriptions.add(subscription);
    return _reminderController.stream;
  }

  /// Get reminders for the current user as a one-time fetch with caching.
  Future<List<ReminderModel>> getRemindersOnce() async {
    if (_currentUser == null) {
      return [];
    }

    if (_cachedReminders != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedReminders!;
    }

    try {
      final querySnapshot = await _firestore
          .collection('reminders')
          .where('userId', isEqualTo: _currentUser.uid)
          .get();

      final reminders = querySnapshot.docs
          .map((doc) => ReminderModel.fromDocument(doc))
          .toList();

      _cachedReminders = reminders;
      _lastFetchTime = DateTime.now();
      return reminders;
    } catch (e) {
      debugPrint('Error fetching reminders once: $e');
      return [];
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
