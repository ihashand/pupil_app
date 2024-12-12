import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/reminder_models/grooming_reminder_model.dart';

/// Service to manage grooming reminders.
class GroomingReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _reminderSubscription;
  final StreamController<List<GroomingReminderModel>> _reminderController =
      StreamController<List<GroomingReminderModel>>.broadcast();

  /// Fetch grooming reminders for the logged-in user as a stream.
  Stream<List<GroomingReminderModel>> getGroomingReminders(String userId) {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _reminderSubscription = _firestore
        .collection('groomingReminders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      final reminders = snapshot.docs.map((doc) {
        return GroomingReminderModel.fromMap(doc.data());
      }).toList();

      reminders.sort((a, b) => a.date.compareTo(b.date));
      _reminderController.add(reminders);
    }, onError: (error) {
      print('Error fetching grooming reminders: $error');
      _reminderController.addError(error);
    });

    return _reminderController.stream;
  }

  /// Add a new grooming reminder.
  Future<void> addGroomingReminder(GroomingReminderModel reminder) async {
    try {
      await _firestore
          .collection('groomingReminders')
          .doc(reminder.id)
          .set(reminder.toMap());
    } catch (e) {
      print('Error adding grooming reminder: $e');
      throw Exception('Failed to add grooming reminder');
    }
  }

  /// Delete a grooming reminder by ID.
  Future<void> deleteGroomingReminder(String reminderId) async {
    try {
      await _firestore.collection('groomingReminders').doc(reminderId).delete();
    } catch (e) {
      print('Error deleting grooming reminder: $e');
      throw Exception('Failed to delete grooming reminder');
    }
  }

  /// Cancel the active grooming reminder stream subscription.
  void cancelSubscription() {
    _reminderSubscription?.cancel();
  }

  /// Dispose the grooming reminder stream controller.
  void dispose() {
    cancelSubscription();
    _reminderController.close();
  }
}
