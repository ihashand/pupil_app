import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/reminder_models/reminder_model.dart';

/// A service class responsible for handling general reminder operations.
///
/// This class provides methods to create, update, delete, and retrieve reminders.
/// It interacts with the underlying data storage to persist reminder information.
class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _reminderSubscription;
  final StreamController<List<ReminderModel>> _reminderController =
      StreamController<List<ReminderModel>>.broadcast();

  /// Get reminders by event ID.
  Future<List<ReminderModel>> getRemindersByEventId(String eventId) async {
    if (_currentUser == null) {
      return [];
    }

    try {
      final querySnapshot = await _firestore
          .collection('reminders')
          .where('userId', isEqualTo: _currentUser!.uid)
          .where('eventId', isEqualTo: eventId)
          .get();

      return querySnapshot.docs
          .map((doc) => ReminderModel.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Error fetching reminders by eventId: $e');
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
    } catch (e) {
      print('Error adding reminder: $e');
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
    } catch (e) {
      print('Error updating reminder: $e');
      throw Exception('Failed to update reminder');
    }
  }

  /// Delete a reminder from the database.
  Future<void> deleteReminder(String reminderId) async {
    try {
      await _firestore.collection('reminders').doc(reminderId).delete();
    } catch (e) {
      print('Error deleting reminder: $e');
      throw Exception('Failed to delete reminder');
    }
  }

  /// Get a stream of reminders for the current user.
  Stream<List<ReminderModel>> getReminderStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _reminderSubscription = _firestore
        .collection('reminders')
        .where('userId', isEqualTo: _currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      final reminders =
          snapshot.docs.map((doc) => ReminderModel.fromDocument(doc)).toList();
      _reminderController.add(reminders);
    }, onError: (error) {
      print('Error in reminder stream: $error');
      _reminderController.addError(error);
    });

    return _reminderController.stream;
  }

  /// Get reminders for the current user as a one-time fetch.
  Future<List<ReminderModel>> getRemindersOnce() async {
    if (_currentUser == null) {
      return [];
    }

    try {
      final querySnapshot = await _firestore
          .collection('reminders')
          .where('userId', isEqualTo: _currentUser!.uid)
          .get();

      return querySnapshot.docs
          .map((doc) => ReminderModel.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Error fetching reminders once: $e');
      return [];
    }
  }

  /// Cancel the active reminder stream subscription.
  void cancelSubscription() {
    _reminderSubscription?.cancel();
  }

  /// Dispose the reminder stream controller.
  void dispose() {
    cancelSubscription();
    _reminderController.close();
  }
}
