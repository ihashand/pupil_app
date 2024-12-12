import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/reminder_models/grooming_reminder_model.dart';

/// Service to manage grooming reminders.
class GroomingReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Cache and subscription management
  List<GroomingReminderModel>? _cachedReminders;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 5);
  final StreamController<List<GroomingReminderModel>> _reminderController =
      StreamController<List<GroomingReminderModel>>.broadcast();
  final List<StreamSubscription> _subscriptions = [];

  /// Fetch grooming reminders for the logged-in user as a stream.
  Stream<List<GroomingReminderModel>> getGroomingReminders(String userId) {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    final subscription = _firestore
        .collection('groomingReminders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      final reminders = snapshot.docs.map((doc) {
        return GroomingReminderModel.fromMap(doc.data());
      }).toList();

      reminders.sort((a, b) => a.date.compareTo(b.date));
      _cachedReminders = reminders;
      _lastFetchTime = DateTime.now();
      _reminderController.add(reminders);
    }, onError: (error) {
      debugPrint('Error fetching grooming reminders: $error');
      _reminderController.addError(error);
    });

    _subscriptions.add(subscription);
    return _reminderController.stream;
  }

  /// Fetch grooming reminders with caching for a one-time operation.
  Future<List<GroomingReminderModel>> getGroomingRemindersOnce(
      String userId) async {
    if (_cachedReminders != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedReminders!;
    }

    try {
      final querySnapshot = await _firestore
          .collection('groomingReminders')
          .where('userId', isEqualTo: userId)
          .get();

      final reminders = querySnapshot.docs.map((doc) {
        return GroomingReminderModel.fromMap(doc.data());
      }).toList();

      reminders.sort((a, b) => a.date.compareTo(b.date));
      _cachedReminders = reminders;
      _lastFetchTime = DateTime.now();
      return reminders;
    } catch (e) {
      debugPrint('Error fetching grooming reminders: $e');
      throw Exception('Failed to fetch grooming reminders');
    }
  }

  /// Add a new grooming reminder.
  Future<void> addGroomingReminder(GroomingReminderModel reminder) async {
    try {
      await _firestore
          .collection('groomingReminders')
          .doc(reminder.id)
          .set(reminder.toMap());
      _cachedReminders = null; // Invalidate cache
    } catch (e) {
      debugPrint('Error adding grooming reminder: $e');
      throw Exception('Failed to add grooming reminder');
    }
  }

  /// Delete a grooming reminder by ID.
  Future<void> deleteGroomingReminder(String reminderId) async {
    try {
      await _firestore.collection('groomingReminders').doc(reminderId).delete();
      _cachedReminders = null; // Invalidate cache
    } catch (e) {
      debugPrint('Error deleting grooming reminder: $e');
      throw Exception('Failed to delete grooming reminder');
    }
  }

  /// Cancel all active subscriptions.
  void cancelAllSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// Dispose the grooming reminder stream controller.
  void dispose() {
    cancelAllSubscriptions();
    _reminderController.close();
  }
}
