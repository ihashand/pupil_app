import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/reminder_models/grooming_reminder_model.dart';

/// Service to manage grooming reminders.
class GroomingReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  /// Fetch grooming reminders for the logged-in user.
  Stream<List<GroomingReminderModel>> getGroomingReminders(String userId) {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('groomingReminders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final reminders = snapshot.docs.map((doc) {
        return GroomingReminderModel.fromMap(doc.data());
      }).toList();

      reminders.sort((a, b) => a.date.compareTo(b.date));
      return reminders;
    });
  }

  /// Add a new grooming reminder.
  Future<void> addGroomingReminder(GroomingReminderModel reminder) async {
    await _firestore
        .collection('groomingReminders')
        .doc(reminder.id)
        .set(reminder.toMap());
  }

  /// Delete a grooming reminder by ID.
  Future<void> deleteGroomingReminder(String reminderId) async {
    await _firestore.collection('groomingReminders').doc(reminderId).delete();
  }
}
