import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_reminder_model.dart';

class EventReminderService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final StreamController<List<EventReminderModel>> _reminderController =
      StreamController.broadcast();

  EventReminderService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  Stream<List<EventReminderModel>> getRemindersStream() {
    if (auth.currentUser == null) {
      return Stream.value([]);
    }

    firestore
        .collection('app_users')
        .doc(auth.currentUser!.uid)
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
    if (auth.currentUser == null) {
      return [];
    }

    final querySnapshot = await firestore
        .collection('app_users')
        .doc(auth.currentUser!.uid)
        .collection('event_reminders')
        .get();

    return querySnapshot.docs
        .map((doc) => EventReminderModel.fromDocument(doc))
        .toList();
  }

  Future<EventReminderModel?> getReminderById(String reminderId) async {
    if (auth.currentUser == null) {
      return null;
    }

    final docSnapshot = await firestore
        .collection('app_users')
        .doc(auth.currentUser!.uid)
        .collection('event_reminders')
        .doc(reminderId)
        .get();

    return docSnapshot.exists
        ? EventReminderModel.fromDocument(docSnapshot)
        : null;
  }

  Future<void> addReminder(EventReminderModel reminder) async {
    await firestore
        .collection('app_users')
        .doc(auth.currentUser!.uid)
        .collection('event_reminders')
        .doc(reminder.id)
        .set(reminder.toMap());
  }

  Future<void> updateReminder(EventReminderModel reminder) async {
    await firestore
        .collection('app_users')
        .doc(auth.currentUser!.uid)
        .collection('event_reminders')
        .doc(reminder.id)
        .update(reminder.toMap());
  }

  Future<void> deleteReminder(String reminderId) async {
    await firestore
        .collection('app_users')
        .doc(auth.currentUser!.uid)
        .collection('event_reminders')
        .doc(reminderId)
        .delete();
  }

  Future<void> removeExpiredReminders() async {
    final reminders = await getReminders();
    final now = DateTime.now();

    for (final reminder in reminders) {
      if (reminder.dateTime.isBefore(now) && reminder.repeatOption == 'Once') {
        await deleteReminder(reminder.id);
      } else if (reminder.repeatOption != 'Once' &&
          reminder.endDate.isBefore(now)) {
        await deleteReminder(reminder.id);
      }
    }
  }

  void dispose() {
    _reminderController.close();
  }
}
