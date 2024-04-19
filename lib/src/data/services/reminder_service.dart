import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/reminder_model.dart';

class ReminderService {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  final _reminderController = StreamController<List<Reminder>>.broadcast();

  Stream<List<Reminder>> getRemindersStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('reminders')
        .snapshots()
        .listen((snapshot) {
      _reminderController
          .add(snapshot.docs.map((doc) => Reminder.fromDocument(doc)).toList());
    });

    return _reminderController.stream;
  }

  Future<List<Reminder>> getReminders() async {
    if (_currentUser == null) {
      return [];
    }

    final querySnapshot = await _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('reminders')
        .get();

    return querySnapshot.docs.map((doc) => Reminder.fromDocument(doc)).toList();
  }

  Future<Reminder?> getReminderById(String reminderId) async {
    if (_currentUser == null) {
      return null;
    }

    final docSnapshot = await _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('reminders')
        .doc(reminderId)
        .get();

    return docSnapshot.exists ? Reminder.fromDocument(docSnapshot) : null;
  }

  Future<void> addReminder(Reminder reminder) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('reminders')
        .doc(reminder.id)
        .set(reminder.toMap());
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('reminders')
        .doc(reminder.id)
        .update(reminder.toMap());
  }

  Future<void> deleteReminder(String reminderId) async {
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('reminders')
        .doc(reminderId)
        .delete();
  }

  void dispose() {
    _reminderController.close();
  }
}
