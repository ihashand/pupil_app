import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/reminder_models/other_reminder_model.dart';
import 'package:pet_diary/src/services/notification_services/notification_services.dart';

/// Service to manage other reminders.
class OtherReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  /// Fetch other reminders for the logged-in user.
  Stream<List<OtherReminderModel>> getOtherReminders(String userId) {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('otherReminders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final reminders = snapshot.docs.map((doc) {
        return OtherReminderModel.fromMap(doc.data());
      }).toList();

      reminders.sort((a, b) => a.date.compareTo(b.date));
      return reminders;
    });
  }

  /// Add a new other reminder.
  Future<void> addOtherReminder(OtherReminderModel reminder) async {
    await _firestore
        .collection('otherReminders')
        .doc(reminder.id)
        .set(reminder.toMap());
  }

  /// Update additional notification IDs for a specific reminder.
  Future<void> updateAdditionalNotificationIds(
      String reminderId, List<int> notificationIds) async {
    await _firestore.collection('otherReminders').doc(reminderId).update({
      'additionalNotificationIds': notificationIds,
    });
  }

  /// Delete an other reminder by ID.
  Future<void> deleteOtherReminder(OtherReminderModel reminder) async {
    try {
      // Delete reminder from the database
      await _firestore.collection('otherReminders').doc(reminder.id).delete();
    } catch (e) {
      throw Exception('Failed to delete other reminder: $e');
    }
  }
}
