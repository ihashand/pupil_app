import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/reminder_models/behaviorist_reminder_model.dart';

/// Service to manage behaviorist reminders.
class BehavioristReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _reminderSubscription;
  final StreamController<List<BehavioristReminderModel>> _reminderController =
      StreamController<List<BehavioristReminderModel>>.broadcast();

  /// Fetch behaviorist reminders for the logged-in user as a stream.
  Stream<List<BehavioristReminderModel>> getBehavioristReminders(
      String userId) {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _reminderSubscription = _firestore
        .collection('behavioristReminders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      final reminders = snapshot.docs.map((doc) {
        return BehavioristReminderModel.fromMap(doc.data());
      }).toList();

      reminders.sort((a, b) => a.date.compareTo(b.date));
      _reminderController.add(reminders);
    }, onError: (error) {
      print('Error fetching behaviorist reminders: $error');
      _reminderController.addError(error);
    });

    return _reminderController.stream;
  }

  /// Add a new behaviorist reminder.
  Future<void> addBehavioristReminder(BehavioristReminderModel reminder) async {
    try {
      await _firestore
          .collection('behavioristReminders')
          .doc(reminder.id)
          .set(reminder.toMap());
    } catch (e) {
      print('Error adding behaviorist reminder: $e');
      throw Exception('Failed to add behaviorist reminder');
    }
  }

  /// Update additional notification IDs for a specific reminder.
  Future<void> updateAdditionalNotificationIds(
      String reminderId, List<int> notificationIds) async {
    try {
      await _firestore
          .collection('behavioristReminders')
          .doc(reminderId)
          .update({'additionalNotificationIds': notificationIds});
    } catch (e) {
      print('Error updating additional notification IDs: $e');
      throw Exception('Failed to update additional notification IDs');
    }
  }

  /// Delete a behaviorist reminder by ID.
  Future<void> deleteBehavioristReminder(String reminderId) async {
    try {
      await _firestore
          .collection('behavioristReminders')
          .doc(reminderId)
          .delete();
    } catch (e) {
      print('Error deleting behaviorist reminder: $e');
      throw Exception('Failed to delete behaviorist reminder');
    }
  }

  /// Cancel the active behaviorist reminder stream subscription.
  void cancelSubscription() {
    _reminderSubscription?.cancel();
  }

  /// Dispose the behaviorist reminder stream controller.
  void dispose() {
    cancelSubscription();
    _reminderController.close();
  }
}
