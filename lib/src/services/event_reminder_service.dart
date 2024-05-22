import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/event_reminder_model.dart';

class EventReminderService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _reminderController =
      StreamController<List<EventReminderModel>>.broadcast();

  Stream<List<EventReminderModel>> getRemindersStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('event_reminders')
        .snapshots()
        .listen((snapshot) {
      _reminderController.add(snapshot.docs
          .map((doc) => EventReminderModel.fromDocument(doc))
          .toList());
    });

    return _reminderController.stream;
  }

  Future<List<EventReminderModel>> getReminders() async {
    if (_currentUser == null) {
      return [];
    }

    final querySnapshot = await _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('event_reminders')
        .get();

    return querySnapshot.docs
        .map((doc) => EventReminderModel.fromDocument(doc))
        .toList();
  }

  Future<EventReminderModel?> getReminderById(String reminderId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot = await _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('event_reminders')
        .doc(reminderId)
        .get();

    return docSnapshot.exists
        ? EventReminderModel.fromDocument(docSnapshot)
        : null;
  }

  Future<void> addReminder(EventReminderModel reminder) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('event_reminders')
        .doc(reminder.id)
        .set(reminder.toMap());
  }

  Future<void> updateReminder(EventReminderModel reminder) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('event_reminders')
        .doc(reminder.id)
        .update(reminder.toMap());
  }

  Future<void> deleteReminder(String reminderId) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('event_reminders')
        .doc(reminderId)
        .delete();
  }

  void dispose() {
    _reminderController.close();
  }
}
