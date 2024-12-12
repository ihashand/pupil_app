import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/reminder_models/other_reminder_model.dart';

/// Service to manage other reminders.
class OtherReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _reminderSubscription;
  final StreamController<List<OtherReminderModel>> _reminderController =
      StreamController<List<OtherReminderModel>>.broadcast();

  /// Fetch other reminders for the logged-in user as a stream.
  Stream<List<OtherReminderModel>> getOtherReminders(String userId) {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _reminderSubscription = _firestore
        .collection('otherReminders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      final reminders = snapshot.docs.map((doc) {
        return OtherReminderModel.fromMap(doc.data());
      }).toList();

      reminders.sort((a, b) => a.date.compareTo(b.date));
      _reminderController.add(reminders);
    }, onError: (error) {
      print('Error fetching other reminders: $error');
      _reminderController.addError(error);
    });

    return _reminderController.stream;
  }

  /// Add a new other reminder.
  Future<void> addOtherReminder(OtherReminderModel reminder) async {
    try {
      await _firestore
          .collection('otherReminders')
          .doc(reminder.id)
          .set(reminder.toMap());
    } catch (e) {
      print('Error adding other reminder: $e');
      throw Exception('Failed to add other reminder');
    }
  }

  /// Update additional notification IDs for a specific reminder.
  Future<void> updateAdditionalNotificationIds(
      String reminderId, List<int> notificationIds) async {
    try {
      await _firestore.collection('otherReminders').doc(reminderId).update({
        'additionalNotificationIds': notificationIds,
      });
    } catch (e) {
      print('Error updating notification IDs: $e');
      throw Exception('Failed to update notification IDs');
    }
  }

  /// Delete an other reminder by ID.
  Future<void> deleteOtherReminder(String reminderId) async {
    try {
      await _firestore.collection('otherReminders').doc(reminderId).delete();
    } catch (e) {
      print('Error deleting other reminder: $e');
      throw Exception('Failed to delete other reminder');
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
