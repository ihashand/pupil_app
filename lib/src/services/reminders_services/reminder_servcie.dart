import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/reminder_models/reminder_model.dart';

/// A service class responsible for handling general reminder operations.
///
/// This class provides methods to create, update, delete, and retrieve reminders.
/// It interacts with the underlying data storage to persist reminder information.
class ReminderService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _reminderController = StreamController<List<ReminderModel>>.broadcast();

  /// Get reminders by event ID.
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

  /// Add a new reminder to the database.
  Future<void> addReminder(ReminderModel reminder) async {
    await _firestore
        .collection('reminders')
        .doc(reminder.id)
        .set(reminder.toMap());
  }

  /// Update an existing reminder in the database.
  Future<void> updateReminder(ReminderModel reminder) async {
    await _firestore
        .collection('reminders')
        .doc(reminder.id)
        .update(reminder.toMap());
  }

  /// Delete a reminder from the database.
  Future<void> deleteReminder(String reminderId) async {
    await _firestore.collection('reminders').doc(reminderId).delete();
  }

  /// Get a stream of reminders for the current user.
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

  /// Get reminders for the current user as a one-time fetch.
  Future<List<ReminderModel>> getRemindersOnce() async {
    if (_currentUser == null) {
      return [];
    }

    final querySnapshot = await _firestore
        .collection('reminders')
        .where('userId', isEqualTo: _currentUser.uid)
        .get();

    return querySnapshot.docs
        .map((doc) => ReminderModel.fromDocument(doc))
        .toList();
  }

  /// Dispose the reminder stream controller.
  void dispose() {
    _reminderController.close();
  }
}
