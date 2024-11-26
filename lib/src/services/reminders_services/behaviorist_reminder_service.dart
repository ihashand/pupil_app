import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/reminder_models/behaviorist_reminder_model.dart';
import 'package:pet_diary/src/services/notification_services/notification_services.dart';

/// Service to manage behaviorist reminders.
class BehavioristReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  /// Fetch behaviorist reminders for the logged-in user.
  Stream<List<BehavioristReminderModel>> getBehavioristReminders(
      String userId) {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('behavioristReminders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final reminders = snapshot.docs.map((doc) {
        return BehavioristReminderModel.fromMap(doc.data());
      }).toList();

      reminders.sort((a, b) => a.date.compareTo(b.date));
      return reminders;
    });
  }

  /// Add a new behaviorist reminder.
  Future<void> addBehavioristReminder(BehavioristReminderModel reminder) async {
    await _firestore
        .collection('behavioristReminders')
        .doc(reminder.id)
        .set(reminder.toMap());
  }

  /// Update additional notification IDs for a specific reminder.
  Future<void> updateAdditionalNotificationIds(
      String reminderId, List<int> notificationIds) async {
    await _firestore.collection('behavioristReminders').doc(reminderId).update({
      'additionalNotificationIds': notificationIds,
    });
  }

  Future<void> deleteBehavioristReminder(String reminderId) async {
    try {
      // Pobierz szczegóły przypomnienia
      final doc = await _firestore
          .collection('behavioristReminders')
          .doc(reminderId)
          .get();
      if (!doc.exists) {
        throw Exception('Reminder not found');
      }

      final reminder = BehavioristReminderModel.fromMap(doc.data()!);

      // Anuluj główne powiadomienie
      await NotificationService().cancelNotification(reminder.hashCode);

      // Anuluj wczesne powiadomienia
      for (final notificationId in reminder.earlyNotificationIds) {
        await NotificationService().cancelNotification(notificationId);
      }

      // Usuń przypomnienie z bazy danych
      await _firestore
          .collection('behavioristReminders')
          .doc(reminderId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete behaviorist reminder: $e');
    }
  }
}
