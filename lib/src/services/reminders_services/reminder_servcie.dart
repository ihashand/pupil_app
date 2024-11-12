import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/reminder_models/reminder_model.dart';

/// A service class responsible for handling reminder-related operations.
///
/// This class provides methods to create, update, delete, and retrieve reminders.
/// It interacts with the underlying data storage to persist reminder information.
class ReminderService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final Duration _cacheDuration = const Duration(minutes: 5);
  List<ReminderModel>? _cachedReminders;
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

  Future<List<ReminderModel>> getRemindersOnce() async {
    if (_cachedReminders != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedReminders!;
    }

    if (_currentUser == null) {
      return [];
    }

    final querySnapshot = await _firestore
        .collection('reminders')
        .where('userId', isEqualTo: _currentUser.uid)
        .get();

    _cachedReminders = querySnapshot.docs
        .map((doc) => ReminderModel.fromDocument(doc))
        .toList();
    _lastFetchTime = DateTime.now();

    return _cachedReminders!;
  }

  Future<ReminderModel?> getReminderById(String reminderId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot =
        await _firestore.collection('reminders').doc(reminderId).get();

    return docSnapshot.exists ? ReminderModel.fromDocument(docSnapshot) : null;
  }

  Future<void> addReminder(ReminderModel reminder) async {
    await _firestore
        .collection('reminders')
        .doc(reminder.id)
        .set(reminder.toMap());
    _cachedReminders = null;
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _firestore
        .collection('reminders')
        .doc(reminder.id)
        .update(reminder.toMap());
    _cachedReminders = null;
  }

  Future<void> deleteReminder(String reminderId) async {
    await _firestore.collection('reminders').doc(reminderId).delete();
    _cachedReminders = null;
  }

  void dispose() {
    _reminderController.close();
  }
}
