import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/reminder_models/grooming_reminder_model.dart';
import 'package:pet_diary/src/services/notification_services/notification_services.dart';

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

  /// Delete a grooming reminder and cancel related notifications.
  Future<void> deleteGroomingReminder(String reminderId) async {
    try {
      // Pobierz szczegóły przypomnienia
      final doc = await _firestore
          .collection('groomingReminders')
          .doc(reminderId)
          .get();
      if (!doc.exists) {
        throw Exception('Reminder not found');
      }

      final reminder = GroomingReminderModel.fromMap(doc.data()!);

      // Anuluj główne powiadomienie
      await NotificationService().cancelNotification(reminder.hashCode);

      // Anuluj wczesne powiadomienia
      for (final notificationId in reminder.earlyNotificationIds) {
        await NotificationService().cancelNotification(notificationId);
      }

      // Usuń przypomnienie z bazy danych
      await _firestore.collection('groomingReminders').doc(reminderId).delete();
    } catch (e) {
      throw Exception('Failed to delete grooming reminder: $e');
    }
  }
}
